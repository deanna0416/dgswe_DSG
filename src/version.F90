      MODULE version
      
      IMPLICIT NONE
      
      CHARACTER(:), ALLOCATABLE :: gitBranch
      CHARACTER(:), ALLOCATABLE :: gitSHA 
      CHARACTER(:), ALLOCATABLE :: compiler_version 
      CHARACTER(:), ALLOCATABLE :: compiler_flags
      CHARACTER(:), ALLOCATABLE :: modified_files
      CHARACTER(:), ALLOCATABLE :: compile_date
      CHARACTER(:), ALLOCATABLE :: host
            
      CONTAINS      
      
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!       
            
      SUBROUTINE version_information(unit)

      IMPLICIT NONE
      
      INTEGER, INTENT(IN) :: unit
      INTEGER :: length,ind,sind,eind        

      gitBranch = ""
      gitSHA = " +28"
      compiler_version = "ifort version 19.1.0.166"
      compiler_flags =  "-Iodir/ -O3  -DMAC"
      modified_files = "../src/plot_mod.F90 ../src/read_plot_input.F90" 
      compile_date =  "Sat Feb 15 15:11:03 MST 2020"
      host =  "cu-biot-7-10 203 155 149 int colorado edu"

      
      length = LEN(TRIM(ADJUSTL(modified_files)))
      
            
      CALL directed_output("Version Information",unit)
      CALL directed_output("  Branch: "//TRIM(ADJUSTL(gitBranch)),unit)
      CALL directed_output("  SHA: "//TRIM(ADJUSTL(gitSHA)),unit)
!       CALL directed_output("  Modified files: ",unit)
! 
!         
!       sind = 1        
!       ind = INDEX(modified_files," ")        
!       eind = ind
!       DO WHILE (ind > 0)
!         CALL directed_output("    " //TRIM(ADJUSTL(modified_files(sind:eind))),unit)
!         sind = eind+1
!         ind = INDEX(modified_files(sind:length)," ")
!         eind = eind + ind
!       ENDDO
        
      CALL directed_output(" ",unit)
      CALL directed_output("Compiler Information",unit)
      CALL directed_output("  Version: "//TRIM(ADJUSTL(compiler_version)),unit)
      CALL directed_output("  Flags: "//TRIM(ADJUSTL(compiler_flags)),unit)
      CALL directed_output("  Date compiled: "//TRIM(ADJUSTL(compile_date)),unit)
      CALL directed_output("  Host: "//TRIM(ADJUSTL(host)),unit)
      CALL directed_output(" ",unit)
     
 
      END SUBROUTINE version_information
      
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
     

      
      END MODULE version
