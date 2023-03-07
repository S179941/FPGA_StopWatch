library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity top is
    port ( clk_i : in STD_LOGIC;
			rst_i : in STD_LOGIC;
			start_stop_button_i : in STD_LOGIC;
			led7_an_o : out STD_LOGIC_VECTOR (3 downto 0);
			led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0));
end top;

architecture ar_top of top is

	signal clk_div : STD_LOGIC := '0';
	signal START : STD_LOGIC := '0';
	signal STOP : STD_LOGIC := '0';
	signal DEBOUNCED_i : STD_LOGIC := '0';
	signal KLIK_1 : STD_LOGIC := '0';

	signal digit_i : STD_LOGIC_VECTOR (31 downto 0) := "00000011000000100000001100000011";
	
	signal ten_seconds : INTEGER range 0 to 11 := 0;
	signal seconds : INTEGER range 0 to 11 := 0;
	signal dot_hundred_seconds : INTEGER range 0 to 11 := 0;
	signal dot_ten_seconds : INTEGER range 0 to 11 := 0;

	component dzielnik_10ms
		port ( clk_i : in STD_LOGIC;
				rst_i : in STD_LOGIC;
				clk_div : out STD_LOGIC);
		end component;

	component display
		port ( clk_i : in STD_LOGIC;
				rst_i : in STD_LOGIC;
				digit_i : in STD_LOGIC_VECTOR (31 downto 0);
				led7_an_o : out STD_LOGIC_VECTOR (3 downto 0);
				led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0));
	end component;

	component debouncer
		port ( key_i : in STD_LOGIC;
				clk_i : in STD_LOGIC;
				key_stable_o : out STD_LOGIC);
	end component;

	component dekoder
		Port (liczba : in INTEGER range 0 to 11;
				seg7 : out STD_LOGIC_VECTOR (6 downto 0));
	end component;

	begin

    i1: dzielnik_10ms port map (clk_i, rst_i, clk_div);
	i2: display port map (clk_i, rst_i, digit_i, led7_an_o, led7_seg_o);
	i3: debouncer port map(start_stop_button_i, clk_div, DEBOUNCED_i);
	i4: dekoder port map(ten_seconds, digit_i(31 downto 25));
	i5: dekoder port map(seconds, digit_i(23 downto 17));
	i6: dekoder port map(dot_hundred_seconds, digit_i(15 downto 9));
	i7: dekoder port map(dot_ten_seconds, digit_i(7 downto 1));

    process (clk_div, rst_i)
    begin
        if (rst_i = '1') then
				ten_seconds <= 0;
				seconds <= 0;
				dot_hundred_seconds <= 0;
				dot_ten_seconds <= 0;
				START <= '0';
				STOP <= '0';
				
        elsif (rising_edge(clk_div)) then
		
            if (START = '0' and STOP = '0' and KLIK_1 = '0' and DEBOUNCED_i = '1') then
                  START <= '1';

            elsif (START = '1' and STOP = '0' and KLIK_1 = '0' and DEBOUNCED_i = '1') then
                  STOP <= '1';

            elsif (START = '1' and STOP = '1' and KLIK_1 = '0' and DEBOUNCED_i = '1') then
                  START <= '0';
                  STOP <= '0';

            elsif (START = '0' and STOP = '0') then
                  dot_ten_seconds <= 0;
				  dot_hundred_seconds <= 0;
				  seconds <= 0;
				  ten_seconds <= 0;                 
            
            elsif (START = '1' and STOP = '0') then
					dot_ten_seconds <= dot_ten_seconds + 1;
					
					if(dot_ten_seconds = 9) then
						dot_ten_seconds <= 0;
						dot_hundred_seconds <= dot_hundred_seconds + 1;
						
						if(dot_hundred_seconds = 9) then
							dot_hundred_seconds <= 0;
							seconds <= seconds + 1;
							
							if(seconds = 9) then
								seconds <= 0;
								ten_seconds <= ten_seconds + 1;
								
								if(ten_seconds = 5) then
									STOP <= '1';
									--MOZE I OBRZYDLIWE ROZWIAZANIE, ALE DZIALA:		  
									ten_seconds <= 11;
									seconds <= 11;
									dot_hundred_seconds <= 11;
									dot_ten_seconds <= 11;
								end if;
							end if;
						end if;
					end if;
				end if;
			KLIK_1 <=  DEBOUNCED_i;	
         end if; 
    end process;
end ar_top;

--TUTAJ JEST DEFINICJA DEKODERA Z CYFRY NA 7-SEG -- UŻYJEMY TAKIEGO 4 RAZY
	
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;

entity dekoder is
    Port ( liczba : in INTEGER range 0 to 11;
			seg7 : out STD_LOGIC_VECTOR (6 downto 0));
end dekoder;

architecture ar_dekoder of dekoder is

	begin
	process(liczba)
		begin
		case liczba is
			when 0 => seg7 <= ("0000001"); -- 0
			when 1 => seg7 <= ("1001111"); -- 1
			when 2 => seg7 <= ("0010010"); -- 2
			when 3 => seg7 <= ("0000110"); -- 3
			when 4 => seg7 <= ("1001100"); -- 4
			when 5 => seg7 <= ("0100100"); -- 5
			when 6 => seg7 <= ("0100000"); -- 6
			when 7 => seg7 <= ("0001111"); -- 7
			when 8 => seg7 <= ("0000000"); -- 8
			when 9 => seg7 <= ("0000100"); -- 9
			when 10 => seg7 <= ("0000001"); -- 10
			when 11 => seg7 <= ("1111110"); -- OVERLOAD
		end case;
	end process;
end ar_dekoder;

-- TUTAJ CZĘŚĆ Z DZIELNIKIEM CZĘSTOTLIWOŚCI JAKO UKŁADEM RTC -- Z POPRZEDNIEGO ZADANIA NAWIASEM MÓWIĄC

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;

entity dzielnik_10ms is
    Port (clk_i : in STD_LOGIC;
			rst_i : in STD_LOGIC;
			clk_div : out STD_LOGIC);
		constant N : integer := 1000000;

end dzielnik_10ms;

architecture ar_dzielnik_10ms of dzielnik_10ms is
	signal wyjscie : STD_LOGIC := '0';
	signal licznik : integer range 0 to ((N/2)-1) := 0;
	
	begin
	process(clk_i, rst_i)
		begin
			if(rst_i = '1') then
				licznik <= 0;
				wyjscie <= '0';
			elsif rising_edge(clk_i) then
				if(licznik = ((N/2)-1)) then
					wyjscie <= NOT(wyjscie);
					licznik <= 0;
				else
					licznik <= licznik + 1;
				end if;
			end if;
	end process;
		clk_div <= wyjscie;
end ar_dzielnik_10ms;

-- TUTAJ CZĘSĆ Z DRGANIEM PRZYCISKÓW

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debouncer is
    Port ( key_i : in STD_LOGIC;
              clk_i : in STD_LOGIC;
           key_stable_o : out STD_LOGIC);
end debouncer;

architecture ar_debouncer of debouncer is
	signal probka_wejsciowa : STD_LOGIC := '0';
	signal poprzednia_probka : STD_LOGIC := '0';
	signal debounced_o : STD_LOGIC := '0';
	
	begin
		process (clk_i) is
		variable okres_drgan : INTEGER range 0 to 6 := 0;
		
		begin
		if rising_edge(clk_i) then
			probka_wejsciowa <= key_i;
			poprzednia_probka <= probka_wejsciowa;
			if (poprzednia_probka = debounced_o) then
				okres_drgan := 0;
			else
				okres_drgan := okres_drgan + 1;
			end if;
			if (okres_drgan = 6) then
				debounced_o <= poprzednia_probka;
				okres_drgan := 0;
			end if;
		end if;
		end process;
		
    key_stable_o <= debounced_o;
end ar_debouncer;
