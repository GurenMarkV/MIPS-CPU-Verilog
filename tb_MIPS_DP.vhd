LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- VHDL testbench code for single-cycle MIPS Processor
ENTITY tb_MIPS_DP IS
END tb_MIPS_DP;
 
ARCHITECTURE behavior OF tb_MIPS_DP IS 
    -- Component Declaration for the single-cycle MIPS Processor in VHDL
    COMPONENT MIPS_DP
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         pc_out : OUT  std_logic_vector(31 downto 0);
         alu_result : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
    --Outputs
   signal pc_out : std_logic_vector(31 downto 0);
   signal alu_result : std_logic_vector(31 downto 0);
   -- Clock period definitions
   constant clk_period : time := 10 ns;
BEGIN
 -- Instantiate the for the single-cycle MIPS Processor in VHDL
   uut: MIPS_DP PORT MAP (
          clk => clk,
          rst => rst,
          pc_out => pc_out,
          alu_result => alu_result
        );

  -- Generate clock stimulus
	clk_gen: process 
	begin -- clock period = 10 ns
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;

		if now >= 2000 ns then -- run for 200 cc
			assert false
			 report "simulation is completed (not error)."
			 severity error;
			wait;
		end if;
	end process;

  data_gen: process 
	begin

			rst <= '1';
			wait for 10 ns;
			rst <= '0';

			wait for 20 ns;
			--start <= '1';

		wait;
   end process;

END;