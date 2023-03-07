library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;

entity display is
    Port ( clk_i : in STD_LOGIC;
           rst_i : in STD_LOGIC;
           digit_i : in STD_LOGIC_VECTOR (31 downto 0);
		   
		   led7_an_o : out STD_LOGIC_VECTOR (3 downto 0);
		   led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0));
end display;

architecture ar_display of display is

	signal clk_div: STD_LOGIC;
	
	component divider
    Port (clk_i : in STD_LOGIC;
			rst_i : in STD_LOGIC;
            clk_div : out STD_LOGIC);
	end component;
	
	component multiplexer
    Port ( clk_div : in STD_LOGIC;
           rst_i : in STD_LOGIC;
           digit_i : in STD_LOGIC_VECTOR (31 downto 0);
		   
		   led7_an_o : out STD_LOGIC_VECTOR (3 downto 0);
		   led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	begin
	
		i1: divider port map (clk_i, '0', clk_div);
		i2: multiplexer port map (clk_div, rst_i, digit_i, led7_an_o, led7_seg_o);
		
end ar_display;


-- TUTAJ CZĘŚĆ Z DZIELNIKIEM CZĘSTOTLIWOŚCI DO MULTIPLEXERA -- Z POPRZEDNIEGO ZADANIA NAWIASEM MÓWIĄC

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;

entity divider is
    Port (clk_i : in STD_LOGIC;
			rst_i : in STD_LOGIC;
			clk_div : out STD_LOGIC);
	constant N : integer := 100000; --DO RZECZYWISTEGO UKŁADU
    --constant N : integer := 4; -- DO SYMULACJI
end divider;

architecture ar_divider of divider is
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
end ar_divider;

-- TUTAJ CZĘŚĆ Z SAMYM MULTIPLEXEREM -- ELEMENT POBUDZANY JUŻ ZEGAREM O ZMNIEJSZONEJ CZĘSTOTLIWOŚCI

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;

entity multiplexer is
    Port ( clk_div : in STD_LOGIC;
           rst_i : in STD_LOGIC;
           digit_i : in STD_LOGIC_VECTOR (31 downto 0);
		   
		   led7_an_o : out STD_LOGIC_VECTOR (3 downto 0);
		   led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0));
end multiplexer;

architecture ar_multiplexer of multiplexer is
	signal act_an : STD_LOGIC_VECTOR (3 downto 0) := "0000";
	signal act_seg : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
	
	begin
	process(clk_div, rst_i)
		begin
			if(rst_i = '1') then
				act_an <= "0000";
				act_seg <= "00000000";
			elsif rising_edge(clk_div) then
				if(act_an = "0111") then
					act_an <= "1011";
					act_seg <= digit_i(23 downto 16);
				elsif(act_an = "1011") then
					act_an <= "1101";
					act_seg <= digit_i(15 downto 8);
				elsif(act_an = "1101") then
					act_an <= "1110";
					act_seg <= digit_i(7 downto 0);
				else
					act_an <= "0111";
					act_seg <= digit_i(31 downto 24);
				end if;
			end if;
	end process;
		led7_an_o <= act_an;
		led7_seg_o <= act_seg;
end ar_multiplexer;