echo "Running ISE"
make TOOL=ise     run > ise_report
echo "Running Vivado"
make TOOL=vivado  run > vivado_report
echo "Running Quartus"
make TOOL=quartus run > quartus_report
echo "Running Libero"
make TOOL=libero  run > libero_report
cat temp-libero/synthesis/backup/Top.srr >> libero_report
echo "Cleaning"
make clean-multi
