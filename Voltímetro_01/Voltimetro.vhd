-- VOLTIMETRO

-- Librerias necesarias
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Definimos la entidad
ENTITY Voltimetro IS
		
		PORT(
		
			-- FPGA
		
			reloj : IN STD_LOGIC;								  -- Reloj interno de la placa
			unidadesDisplay : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);  -- Valor de las unidades a mostrar en el display
			decimalesDisplay : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- Valor de los decimales a mostrar en el display
			puntoDisplay : OUT STD_LOGIC;						  -- Punto que separa la parte entera de la decimal
			segundoPunto : OUT STD_LOGIC;						  -- Lo consideramos para apagarlo
			
			-- Conversor A/D : Los puertos de entrada del conversor son en realidad salidas de la FPGA
			-- Las salidas del conversor son entradas a la FPGA
			
			-- FISICO IN_AD : OUT STD_LOGIC_VECTOR;      -- Entradas analogicas
			A : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);		 -- Seleccion del canal analogico a convertir
			D : IN STD_LOGIC_VECTOR (7 DOWNTO 0); 		 -- Salida digital de la senial analogica seleccionada
			-- REFPOS : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- Entrada de la tension de referencia positiva
			-- REFNEG : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- Entrada de la tension de referencia negativa
			-- PWRDN : OUT STD_LOGIC; 						 -- Apaga el convertidor para minimizar el consumo del sistema
			MODE : OUT STD_LOGIC; 						 -- Selecciona el MODE_0 o MODE_1
			RD : OUT STD_LOGIC; 					     -- Marca el inicio de la conversion
			-- WR_RDY : OUT STD_LOGIC; 					 -- Marca la escritura del dato o bien que la conversion ha finalizado
			CS : OUT STD_LOGIC; 						 -- Marca el inicio de la conversion
			INT : IN STD_LOGIC
		);
			
END Voltimetro;

-- Definimos la arquitectura
ARCHITECTURE arquitecturaVoltimetro OF Voltimetro IS
	
	SIGNAL senialMuestreo : STD_LOGIC;			     -- Marca las subidas y bajadas de la senial de muestreo a frecuencia 10^6
	SIGNAL voltaje : STD_LOGIC_VECTOR (7 DOWNTO 0);	 -- Valor del voltaje digitalizado a 8 bits
	SIGNAL unidades : INTEGER RANGE 0 TO 9;			 -- Valor de las unidades obtenido a partir del voltaje
	SIGNAL decimales : INTEGER RANGE 0 TO 9;		 -- Valor de los decimales obtenido a partir del voltaje
	
	-- Instanciamos el codificador de 7 segmentos para la representacion mediante display
	COMPONENT codificador7Segmentos
	
		PORT(
			
			entrada : IN INTEGER RANGE 0 TO 9;
			salida  : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		
		);
			
	END COMPONENT;

	BEGIN
	
		-- Vamos a considerar la primera entrada, por tanto, seleccionamos el primer canal
		A <= "000";
		-- Seleccionamos MODO 0
		MODE <= '0';
		
		-- Asignamos a CS y RD la frecuencia de muestreo que hemos creado
		CS <= senialMuestreo;
		RD <= senialMuestreo;
		
		puntoDisplay <= '0';    -- Lo mantenemos siempre encendido
		segundoPunto <= '1';    -- Apagamos el segundo punto del display
			
		-- Obtenemos la frecuencia de muestreo
		obtencionFrecuenciaMuestreo : PROCESS (reloj)
			
			VARIABLE i : INTEGER RANGE 0 TO 25000 := 0;	
	
			BEGIN
		
			IF reloj'EVENT AND reloj = '1' THEN
		
				IF i = 12500 THEN		
					senialMuestreo <= NOT senialMuestreo;
					i := 0;	
				ELSE
					i := i + 1;	
				END IF;
				
			END IF;
	
		END PROCESS obtencionFrecuenciaMuestreo;
		
		
		-- Con este proceso lo que haremos sera obtener el voltaje a partir del conversor A/D
		obtencionVoltaje : PROCESS (INT)
	
			BEGIN
			
			IF INT'EVENT AND INT = '1' THEN
				voltaje <= D;
			END IF;
			
		END PROCESS obtencionVoltaje;
		
		
		-- Con este proceso lo que haremos es obtener las unidades y la parte decimal del voltaje
		obtencionValoresDisplay : PROCESS (voltaje)
		
			VARIABLE voltajeEntero : INTEGER RANGE 0 TO 300;
		
			BEGIN
			
			voltajeEntero := conv_integer(voltaje);				-- Pasamos el voltaje a entero
			voltajeEntero := 50*(voltajeEntero)/255;
			unidades <= voltajeEntero / 10;						-- Obtenemos el valor de las unidades
			decimales <= voltajeEntero REM 10;					-- Obtenemos el valor de los decimales
	
		END PROCESS obtencionValoresDisplay;
		
		
		-- Codificamos para mostrar por el display de 7 segmentos las unidades
		mostrarUnidadesDisplay : codificador7Segmentos PORT MAP(
		
			entrada => unidades,
			salida => unidadesDisplay
				
		);
		
		-- Codificamos para mostrar por el display de 7 segmentos los decimales
		mostrarDecimalesDisplay : codificador7Segmentos PORT MAP(
				
			entrada => decimales,
			salida => decimalesDisplay
				
		);
	
END arquitecturaVoltimetro;