LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY LIGHTING_CONTROL IS
	PORT(
		-- Input ports
		INPUT_SIGNAL	: 	IN    	STD_LOGIC_VECTOR(159 DOWNTO 0);	--arbitrary input vector...
		LP_I2C_LP_REQ	:	IN		STD_LOGIC;
		-- Output ports
		LIGHTING_VAL_1	:	OUT	STD_LOGIC;
		LIGHTING_VAL_2	:	OUT	STD_LOGIC;
		OUTPUT_SIGNAL	: 	OUT	STD_LOGIC_VECTOR(159 DOWNTO 0)
	);
END ENTITY LIGHTING_CONTROL;

ARCHITECTURE archi OF LIGHTING_CONTROL IS
	CONSTANT LIGHTING_HIGH		:		STD_LOGIC			:=		'1'; --or something
	CONSTANT LIGHTING_LOW		:		STD_LOGIC			:=		'0'; --or something
	CONSTANT NOISE_LEVEL			:		INTEGER				:=		100; --or something
	CONSTANT THRESHOLD			:		INTEGER				:=		2000; --or something
	--SIGNAL INPUT_SIGNAL_PREV	:		STD_LOGIC_VECTOR(159 DOWNTO 0);
	TYPE INT_ARRAY IS ARRAY(9 DOWNTO 0) OF INTEGER;
	SIGNAL CH1_PAST_VALUES	:		INT_ARRAY			:= (OTHERS => 3000); --past 10 values?
	SIGNAL CH2_PAST_VALUES	:		INT_ARRAY			:= (OTHERS => 3000); --past 10 values?

BEGIN
	PROCESS(LP_I2C_LP_REQ)
	VARIABLE CH1_CURRENT_VALUE	:		INTEGER;	
	VARIABLE CH2_CURRENT_VALUE	:		INTEGER;	
	VARIABLE CH1_MIN_VALUE			:		INTEGER;
	VARIABLE CH2_MIN_VALUE			:		INTEGER;
	VARIABLE LIGHTING_VAL_1_COPY	:		STD_LOGIC;
	VARIABLE LIGHTING_VAL_2_COPY	:		STD_LOGIC;
	VARIABLE INPUT_SIGNAL_PREV	:		STD_LOGIC_VECTOR(159 DOWNTO 0);
	
	BEGIN
		IF (rising_edge(LP_I2C_LP_REQ)) THEN
			CH1_MIN_VALUE := 4095;
			CH2_MIN_VALUE := 4095;
			
			FOR COUNTER in CH1_PAST_VALUES'range LOOP
				IF CH1_MIN_VALUE > CH1_PAST_VALUES(COUNTER) THEN
					CH1_MIN_VALUE := CH1_PAST_VALUES(COUNTER);
				END IF;			
				IF CH2_MIN_VALUE > CH2_PAST_VALUES(COUNTER) THEN
					CH2_MIN_VALUE := CH2_PAST_VALUES(COUNTER);
				END IF;
			END LOOP;
			
			--determine lighting val
			CH1_CURRENT_VALUE := TO_INTEGER(UNSIGNED(INPUT_SIGNAL(15 downto 8) & INPUT_SIGNAL(23 downto 20)));
			IF (CH1_CURRENT_VALUE > CH1_MIN_VALUE) AND (CH1_CURRENT_VALUE - CH1_MIN_VALUE > NOISE_LEVEL) THEN
				LIGHTING_VAL_1 <= LIGHTING_HIGH;
				LIGHTING_VAL_1_COPY := LIGHTING_HIGH;
			ELSE
				LIGHTING_VAL_1 <= LIGHTING_LOW;
				LIGHTING_VAL_1_COPY := LIGHTING_LOW;
			END IF;
			CH1_PAST_VALUES <= (CH1_PAST_VALUES(8 DOWNTO 0) & CH1_CURRENT_VALUE);
			
			CH2_CURRENT_VALUE := TO_INTEGER(UNSIGNED(INPUT_SIGNAL(31 downto 24) & INPUT_SIGNAL(39 downto 36)));
			LIGHTING_VAL_2 <= LIGHTING_LOW;
			IF (CH2_CURRENT_VALUE > CH2_MIN_VALUE) AND (CH2_CURRENT_VALUE - CH2_MIN_VALUE > NOISE_LEVEL) THEN
				LIGHTING_VAL_2_COPY := LIGHTING_HIGH;
			ELSE
				LIGHTING_VAL_2_COPY := LIGHTING_LOW;
			END IF;		
			CH2_PAST_VALUES <= (CH2_PAST_VALUES(8 DOWNTO 0) & CH2_CURRENT_VALUE);
			
			--modify vector st OUTPUT_SIGNAL <= [INPUT_SIGNAL 159 DOWNTO 48][LIGHTING HIGH/LOW][CH2 VALUE][CH1 VALUE][INPUT_SIGNAL 8 DOWNTO 0]
			OUTPUT_SIGNAL <= INPUT_SIGNAL(159 downto 48) & "000000" & LIGHTING_VAL_2_COPY & LIGHTING_VAL_1_COPY & INPUT_SIGNAL(39 downto 0);
		END IF;		
	END PROCESS;
END archi;