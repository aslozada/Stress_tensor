#author: Asdrubal Lozada
#e-mail bug report to: aslozada@gmail.com
#github.com/aslozada
#-----------------------------------------
#path-packets.sh calculates the Path-Packets {q,q'} as described in Jenkins & Kirk. Next Generation Quantum Theory of Atoms in Molecules: From Stereochemistry to Photochemistry and Molecular Devices (2023)
# To obtain the full bond-path framework B = ({p,p'}, {q,q'}, {r}} add the "first eigenvector" in get_packets function
#
#>This script requires Multiwfn version 3.8(dev) Update [2024-Nov-13]
#---------------------
#!/usr/bin env bash

clear_all() {
  rm -rf data_a.txt
  rm -rf data_b.txt  
}

check_arguments() {
  if [ $# -ne 1 ]; then
     echo "Usage: $0 <waveFunction_file>"
     echo "path-packets requires Multiwfn version 3.8(dev) update [2024-nov-13]"
     exit 1
  fi
}

inquire_file() {
  local filename=$1

  if [ ! -f "$filename" ]; then
     echo "File not found: $filename"
     exit 1
  fi  
}

# searches by critical points in the electron density
search_cps() {
  arr=(2 -11 1 6 -1 -9 -4 4 0 0 -10 "q")
  options="data_a.txt"
  
  echo "${arr[0]}" >> "$options" # activate the topology module
  echo "${arr[1]}" >> "$options" # choose function
  echo "${arr[2]}" >> "$options" # electron density
  echo "${arr[3]}" >> "$options" # search from batch of points
  echo "${arr[4]}" >> "$options" # using each nucleus
  echo "${arr[5]}" >> "$options" # return
  echo "${arr[6]}" >> "$options" # save cps
  echo "${arr[7]}" >> "$options" # save critical points in CPs.txt
  echo "${arr[8]}" >> "$options" # return
  echo "${arr[9]}" >> "$options" # show cps
  echo "${arr[10]}" >> "$options" # return
  echo "${arr[11]}" >> "$options" # quit

}

get_paths() {
  arr=(2 -11 1 -4 5 "CPs.txt" 0 8 -5 4 0 -10 "q")
  
  options="data_b.txt"

  echo "${arr[0]}" >> "$options" # activate the topology module
  echo "${arr[1]}" >> "$options" # choose function
  echo "${arr[2]}" >> "$options" # electron density
  echo "${arr[3]}" >> "$options" # call cps file
  echo "${arr[4]}" >> "$options" # load cps file
  echo "${arr[5]}" >> "$options" # 
  echo "${arr[6]}" >> "$options" # 
  echo "${arr[7]}" >> "$options" # 
  echo "${arr[8]}" >> "$options" # 
  echo "${arr[9]}" >> "$options" # 
  echo "${arr[10]}" >> "$options" # 
  echo "${arr[11]}" >> "$options" # 
  echo "${arr[12]}" >> "$options" # 
    

}

get_points() {
  paths="paths.txt"
  exec 10<"paths.txt"
  read -r num <&10

  rm -rf coor.txt
  rm -rf coor1.txt

  echo "1" > coor.txt

  for ((i = 1; i <= $num; i++ )); do
    read -r _ <&10
    read -r _ <&10
    read -r val <&10

    for ((j = 1; j <= $val; j++ )); do
      read -r x y z <&10
      echo "$x" "$y" "$z" >> coor.txt
      echo "$x" "$y" "$z" >> coor1.txt
      echo "1" >> coor.txt
    done
  done 
  
  echo "q" >> coor.txt
  echo "q" >> coor.txt

  exec 10<&-
}

get_packets() {

file="tmp1"
rm -rf output.txt
block_counter=1

grep -n "Eigenvectors (columns) of stress tensor:" "$file" | cut -d: -f1 | while read -r line_number; do
    block=$(sed -n "${line_number},+7p" "$file")
    ellipticity=$(echo "$block" | grep "Stress tensor ellipticity:" | awk '{print $4}')

    second_vector=$(echo "$block" | grep -A 3 "Eigenvectors (columns) of stress tensor:" | tail -n 3 | awk '{print $2}')
    
    echo "$second_vector" | awk -v e="$ellipticity" '{printf "%.10f ", $1 * e}' >> output.txt
    echo >> output.txt
    
    ((block_counter++))
done

file2="output.txt"
file1="coor1.txt"

result_file="packets.xyz"

> "$result_file"

nat=`grep -c '.' coor1.txt`
nat=$( expr $nat \* 2 )

echo "$nat" >> "$result_file"
echo "Packet-Paths" >> "$result_file"

paste "$file1" "$file2" | while read -r line; do
    col1_file1=$(echo "$line" | awk '{print $1}')
    col2_file1=$(echo "$line" | awk '{print $2}')
    col3_file1=$(echo "$line" | awk '{print $3}')
    col1_file2=$(echo "$line" | awk '{print $4}')
    col2_file2=$(echo "$line" | awk '{print $5}')
    col3_file2=$(echo "$line" | awk '{print $6}')
    
    result1=$(awk "BEGIN {printf \" %.10f\", $col1_file1 + $col1_file2}")
    result2=$(awk "BEGIN {printf \" %.10f\", $col2_file1 + $col2_file2}")
    result3=$(awk "BEGIN {printf \" %.10f\", $col3_file1 + $col3_file2}")
    
    result4=$(awk "BEGIN {printf \" %.10f\", $col1_file1 - $col1_file2}")
    result5=$(awk "BEGIN {printf \" %.10f\", $col2_file1 - $col2_file2}")
    result6=$(awk "BEGIN {printf \" %.10f\", $col3_file1 - $col3_file2}")
    
    echo "N $result1 $result2 $result3" >> "$result_file"
    echo "O $result4 $result5 $result6" >> "$result_file"
done

}

format_cps() {
input_file="CPs.txt"
rm -rf cps_format.xyz

head -n 1 "$input_file" >> cps_format.xyz
echo >> cps_format.xyz

tail -n +2 "$input_file" | while read -r line; do
    column5=$(echo "$line" | awk '{print $5}')
    
    if [ "$column5" -eq 1 ]; then
        new_first_column="Cl"
    elif [ "$column5" -eq 2 ]; then
        new_first_column="S"
    fi
    
    echo "$line" | awk -v new_first_column="$new_first_column" '{ $1 = new_first_column; print }' >> cps_format.xyz
done

}	


call_multiwfn() {
  local waveFunction=$1
  local condition=$2

  if ! command -v Multiwfn &> /dev/null
  then
    echo "Multiwfn aren't installed"
    exit 1
  fi
  
  search_cps
  get_paths

  ./Multiwfn $waveFunction -silent < data_a.txt > tmp

#  clear
  
  grep 'Fine, Poincare-Hopf relationship is satisfied' tmp > /dev/null 2>&1
  result=$?

  if [ $result -eq 0 ]; then
     echo "Poincare-Hopf relationship is OK!"
  else
     echo "Warning: Poincare-Hopf relationship is not satisified."
  fi

  ./Multiwfn $waveFunction -silent < data_b.txt > tmp0
  
  echo ""
  echo "-------------------------------------"
  echo " Wait ... getting the Path-Packets"
  echo "-------------------------------------"
  

  get_points
  ./Multiwfn $waveFunction -silent < coor.txt > tmp1

  get_packets

  echo "Path-Packets saved in: paths.xyz"
  echo "Critical points saved in: cps_format.xyz"

  echo "To visualize, use VMD with CPK representation."
}

main() {
  local filename=$1

  clear_all
  check_arguments "$@"
  inquire_file "$filename"
  call_multiwfn $filename
  
  format_cps

  # clean temporary files
  rm -rf tmp tmp0 tmp1 paths.txt CPs.txt coor.txt coor1.txt output.txt
  rm -rf data_a.txt data_b.txt

 
}

main "$@"

