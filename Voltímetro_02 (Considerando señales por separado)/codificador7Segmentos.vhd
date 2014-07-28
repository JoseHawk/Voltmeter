-- CODIFICADOR 7 SEGMENTOS

-- Librerias necesarias
library ieee;
use ieee.std_logic_1164.all;

ENTITY codificador7Segmentos IS
      
	PORT (
      
		entrada : IN INTEGER RANGE 0 TO 9;
		salida : OUT STD_lOGIC_VECTOR (6 DOWNTO 0)
	
	);
	
END codificador7Segmentos;

ARCHITECTURE arquitecturaCodificador7Segmentos OF codificador7Segmentos IS
      
      BEGIN
      
      codificacion : PROCESS (entrada)
      
      BEGIN
      
		CASE entrada IS
      
			WHEN 0 => salida <= "0000001";
			WHEN 1 => salida <= "1001111";
			WHEN 2 => salida <= "0010010";
			WHEN 3 => salida <= "0000110";
			WHEN 4 => salida <= "1001100";
			WHEN 5 => salida <= "0100100";
			WHEN 6 => salida <= "1100000";
			WHEN 7 => salida <= "0001111";
			WHEN 8 => salida <= "0000000";
			WHEN 9 => salida <= "0001100";
		
		END CASE;
		
      END PROCESS codificacion;
      
END arquitecturaCodificador7Segmentos;