library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_tb is
end top_tb;

architecture ar_top_tb of top_tb is

	component top is
		Port (clk_i : in STD_LOGIC;
				rst_i : in STD_LOGIC;
				start_stop_button_i : in STD_LOGIC;
				led7_an_o : out STD_LOGIC_VECTOR (3 downto 0);
				led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0));
	end component top;

	signal clk_i : STD_LOGIC := '0';
	signal rst_i : STD_LOGIC := '0';
	signal start_stop_button_i : STD_LOGIC := '0';
	
	signal led7_an_o : STD_LOGIC_VECTOR (3 downto 0);
	signal led7_seg_o : STD_LOGIC_VECTOR (7 downto 0);
	

	begin
	
		dut: top port map (clk_i, rst_i, start_stop_button_i, led7_an_o, led7_seg_o);


		clk_i <= not clk_i after 5 ns;

		process
			begin 
			
			start_stop_button_i <= '1';
			wait for 80 ms;
			start_stop_button_i <= '0';
			
			wait for 1340 ms;
			
			start_stop_button_i <= '1';
			wait for 80 ms;
			start_stop_button_i <= '0';
			
			wait for 400 ms;
			
			start_stop_button_i <= '1';
			wait for 80 ms;
			start_stop_button_i <= '0';
				
			wait;
		end process;



end ar_top_tb;