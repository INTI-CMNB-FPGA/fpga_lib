class fpga_db:

   version = "0.3.0"

   tools = ['vivado','ise','quartus','libero']

   boards = {
      'avnet_s6micro' : {
         'full_name' : 'Avnet Spartan-6 FPGA LX9 MicroBoard',
         'fpga_name' : 'xc6slx9-csg324',
         'fpga_pos'  : '1',
         'spi_name'  : 'N25Q128',
         'spi_width' : '4'
      },
      'digilent_atlys' : {
         'full_name' : 'Digilent Atlys - Comprehensive Spartan 6 Design Platform',
         'fpga_name' : 'xc6slx45-csg324',
         'fpga_pos'  : '1',
         'spi_name'  : 'N25Q12',
         'spi_width' : '4'
      },
      'gaisler_xc6s' : {
         'full_name' : 'Gaisler Research GR-XC6S',
         'fpga_name' : 'xc6slx75-2-fgg484',
         'fpga_pos'  : '1',
         'spi_name'  : 'W25Q64BV',
         'spi_width' : '4'
      },
      'microsemi_m2s090ts' : {
         'full_name' : 'Gaisler Research GR-XC6S',
         'fpga_name' : 'Microsemi M2S090TS-EVAL-KIT',
         'fpga_pos'  : '1',
         'spi_name'  : 'W25Q64FVSSIG',
         'spi_width' : '1'
      },
      'terasic_de0nano' : {
         'full_name' : 'Terasic DE0-Nano development and education board',
         'fpga_name' : 'EP4CE22F17C6',
         'fpga_pos'  : '1',
         'spi_name'  : 'EPCS64',
         'spi_width' : '4'
      },
      'xilinx_ml605' : {
         'full_name' : 'Xilinx Virtex 6 ML605',
         'fpga_name' : 'xc6vlx240t-1-ff1156',
         'fpga_pos'  : '2',
         'bpi_name'  : '28F256P30',
         'bpi_width' : '16'
      },
      'xilinx_sp601' : {
         'full_name' : 'Xilinx Spartan 6 SP601',
         'fpga_name' : 'xc6slx16-2-csg324',
         'fpga_pos'  : '1',
         'spi_name'  : 'W25Q64BV',
         'spi_width' : '1',
         'bpi_name'  : '28F128J3D',
         'bpi_width' : '8'
      }
   }

if __name__ == "__main__":
   for board in sorted(fpga_db.boards):
       print("%s:" % (board))
       for key,value in sorted(fpga_db.boards[board].items()):
           print ("* %-10s-> %s" % (key,value))
