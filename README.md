# Stress_tensor
Patch to calculate the stress tensor matrix in Multiwfn.

How to get the path-packets?

The bash script path-packets.sh uses Multiwfn version 3.8 (dev) Update [2024-Nov-13]. Released in http://sobereva.com/multiwfn/

```
cd Multiwfn
patch < patch_packets.path
make -j #

```
```
bash path-packets.sh <waveFunctionFile>

```
See: http://sobereva.com/wfnbbs/viewtopic.php?id=954 and http://sobereva.com/wfnbbs/viewtopic.php?id=1540

### Stress tensor stiffness
Biphenyl C12H10 (B3LYP / 6-311G(2d,2p))

![Stiffness](https://github.com/user-attachments/assets/d3816cd5-ae50-4826-ab45-f46d577b21f8)

### Stress tensor ellipticity
![Ellipticity](https://github.com/user-attachments/assets/092529f6-b7f1-46bd-8ced-69902fcab9a3)

### Path-Packets 
Dimer Li-Li (CAM-B3LYP / ANO-RCC-FULL)
![Li2-paths-packets](https://github.com/user-attachments/assets/a93a6798-cbc1-467f-978f-70167787dc2f)

### Path-Packets
Ethene C2H4 (B3LYP / DEF2-TZVP)
![ethene-path-packets](https://github.com/user-attachments/assets/fcf9622a-7928-4c9e-97af-828f09774f89)

