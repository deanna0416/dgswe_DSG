      MODULE allocation

      USE globals, ONLY: nel_type,norder,ne,nn,nrblk, &
                         mndof,mnqpte,mnqpta,mnepn,mnnds,mnp, &
                         ned,nied,nobed,nnfbed,nfbed, &
                         nope,neta,nbou,nvel, &
                         nobfr,nfbfr,nfbsfr
      USE messenger2, ONLY: mnelred,mnired,nred,nthreads
      USE read_dginp, ONLY: npart


      IMPLICIT NONE

      CONTAINS

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE sizes()

      USE globals, ONLY: ndof,nverts,np,nnds,order, &
                         mndof,mnp,mnnds
      USE read_dginp, ONLY: p,ctp,hbp

      IMPLICIT NONE

      ndof(1) = (p+1)*(p+2)/2
      ndof(2) = (p+1)**2
      ndof(3) = ndof(1)
      ndof(4) = ndof(2)
      ndof(5) = (p+1)*(p+2)/2   ! DSG added for IGA elements
      mndof = maxval(ndof)

      nverts(1) = 3
      nverts(2) = 4
      nverts(3) = 3
      nverts(4) = 4
!      nverts(5) = 10  ! DSG added for IGA elements
      nverts(5) = 6  ! DSG added for IGA elements


      np(1) = 1
      np(2) = 1
      np(3) = ctp
      np(4) = ctp
      np(5) = hbp
      np(6) = hbp
 !     np(7) = 3  ! DSG added for cubic IGA elements
      np(7) = 2  ! DSG added for QUADRATIC IGA elements
      mnp = maxval(np)+1

      nnds(1) = 3
      nnds(2) = 4
      nnds(3) = (ctp+1)*(ctp+2)/2
      nnds(4) = (ctp+1)*(ctp+1)
      nnds(5) = (hbp+1)*(hbp+2)/2
      nnds(6) = (hbp+1)*(hbp+1)
!      nnds(7) = 10 ! DSG added for IGA elements
      nnds(7) = 6 ! DSG added for IGA elements

      mnnds = maxval(nnds)


      order(1) = 1
      order(2) = 2
      order(3) = 3
      order(4) = 4
!      order(5) = 5!!!!
      order(5) = 7
      order(6) = 5
      order(7) = 6
      order(8) = 5
      order(9) = 6  ! DSG added for IGA elements
      order(10) = 7    ! DSG added for IGA elements

#ifdef openmp
      IF (npart < nthreads) THEN
        npart = nthreads
      ENDIF
#endif

      RETURN
      END SUBROUTINE sizes

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE alloc_grid_arrays(stage)

      USE globals, ONLY: ect,xy,depth,el_type,elxy,elhb,nepn, &
                         obseg,obnds,fbseg,fbnds

      IMPLICIT NONE
      INTEGER :: stage
      INTEGER :: n,i
      INTEGER :: alloc_status(3)

      alloc_status(:) = 0

      IF (stage == 1) THEN
        n = 3
        ! Node information
        ALLOCATE(ect(mnnds,ne),xy(2,nn),depth(nn),el_type(ne),STAT = alloc_status(1))
        ALLOCATE(elxy(mnnds,ne,2),elhb(mnnds,ne), STAT = alloc_status(2))
        ALLOCATE(nepn(nn),STAT = alloc_status(3))
      ELSE IF (stage == 2) THEN
        n = 1
        ! Open boundary information
        ALLOCATE(obseg(nope),obnds(neta,nope), STAT = alloc_status(1))
      ELSE IF (stage == 3) THEN
        n = 1
        ! Flow boundary information
        ALLOCATE(fbseg(2,nbou),fbnds(nvel,nbou),STAT = alloc_status(1))
      ENDIF



      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_grid_arrays"
          PRINT*, "Stage = ", stage
          STOP
        ENDIF
      ENDDO


      RETURN
      END SUBROUTINE alloc_grid_arrays

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE alloc_forcing_arrays(stage)

      USE globals, ONLY: obtag,obfreq,obnfact,obeq,obper,obtag2,obamp,obph, &
                         fbtag,fbfreq,fbnfact,fbeq,fbper,fbtag2,fbamp,fbph, &
                         obamp_qpt,obph_qpt,obdepth_qpt, &
                         fbamp_qpt,fbph_qpt, &
                         fbstag,fbstag2,fbsbgn,fbsend,fbssig,fbsamp, &
                         fbsamp_qpt


      IMPLICIT NONE
      INTEGER :: stage
      INTEGER :: n,i
      INTEGER :: alloc_status(4)

      alloc_status(:) = 0

      IF (stage == 1) THEN
        n = 2
        ! Open boundary forcing arrays

        ALLOCATE(obtag(nobfr),obfreq(nobfr),obnfact(nobfr),obeq(nobfr),obper(nobfr),STAT = alloc_status(1))
        ALLOCATE(obtag2(nobfr),obamp(neta,nope,nobfr),obph(neta,nope,nobfr),STAT = alloc_status(2))

      ELSE IF (stage == 2) THEN
        n = 2
        ! Flow boundary forcing arrays
        ALLOCATE(fbtag(nfbfr),fbfreq(nfbfr),fbnfact(nfbfr),fbeq(nfbfr),fbper(nfbfr),STAT = alloc_status(1))
        ALLOCATE(fbtag2(nfbfr),fbamp(nvel,nbou,nfbfr),fbph(nvel,nbou,nfbfr),STAT = alloc_status(2))
      ELSE IF (stage == 3) THEN
        n = 2
        ! Flow boundary surge arrays
        ALLOCATE(fbstag(nfbsfr),fbstag2(nfbsfr),fbsbgn(nfbsfr),fbsend(nfbsfr),fbssig(nfbsfr),STAT = alloc_status(1))
        ALLOCATE(fbsamp(nvel,nbou,nfbsfr),STAT = alloc_status(2))
      ELSE IF (stage == 4) THEN
        n = 4
        ! Boundary information interpolated to quadrature points
        ALLOCATE(obamp_qpt(nobfr,mnqpte,nobed),obph_qpt(nobfr,mnqpte,nobed),STAT=alloc_status(1))
        ALLOCATE(obdepth_qpt(nobed,mnqpte),STAT=alloc_status(2))
        ALLOCATE(fbamp_qpt(nfbfr,mnqpte,nfbed),fbph_qpt(nfbfr,mnqpte,nfbed),STAT=alloc_status(3))
        ALLOCATE(fbsamp_qpt(nfbsfr,mnqpte,nfbed) ,STAT=alloc_status(4))
      ENDIF



      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_forcing_arrays"
          PRINT*, "Stage = ", stage
          STOP
        ENDIF
      ENDDO


      RETURN
      END SUBROUTINE alloc_forcing_arrays

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE alloc_connect_arrays(stage)

      USE globals, ONLY: epn,ged2nn,ged2el,ged2led,&
                         iedn,obedn,fbedn,nfbedn,nfbednn, &
                         ed_type

      IMPLICIT NONE
      INTEGER :: stage
      INTEGER :: n,i
      INTEGER :: alloc_status(3)

      alloc_status(:) = 0

      IF (stage == 1) THEN
        n = 1
        ! Elements associated with each node
        ALLOCATE(epn(mnepn,nn),STAT = alloc_status(1))
      ELSE IF (stage == 2) THEN
        n = 2
        ! Edge look-up tables
        !ALLOCATE(ged2nn(2,ned),ged2el(2,ned),ged2led(2,ned),STAT = alloc_status(1))
        ALLOCATE(ged2nn(4,ned),ged2el(2,ned),ged2led(2,ned),STAT = alloc_status(1))
        ALLOCATE(ed_type(ned), STAT = alloc_status(2))
      ELSE IF (stage == 3) THEN
        n = 3
        ! Edge look-up tables
        ALLOCATE(iedn(nied),STAT = alloc_status(1))
        ALLOCATE(obedn(nobed),STAT = alloc_status(2))
        ALLOCATE(fbedn(nfbed),nfbedn(nnfbed),nfbednn(nnfbed,2),STAT=alloc_status(3))
      ENDIF



      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_connect_arrays"
          PRINT*, "Stage = ", stage
          STOP
        ENDIF
      ENDDO

      RETURN
      END SUBROUTINE alloc_connect_arrays


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE alloc_qpt_arrays(stage)

      USE globals, ONLY: qpta,wpta,wpte,qpte

      IMPLICIT NONE
      INTEGER :: stage
      INTEGER :: n,i
      INTEGER :: alloc_status(2)

      alloc_status(:) = 0

      IF (stage == 1) THEN
        n = 2
        ! Area quadrature points and weights
        ALLOCATE(qpta(mnqpta,2,nel_type),STAT = alloc_status(1))
        ALLOCATE(wpta(mnqpta,nel_type),STAT = alloc_status(2))
      ELSE IF (stage == 2) THEN
        n = 2
        ! Edge quadrature points and weights
        ALLOCATE(qpte(4*mnqpte,2,nel_type),STAT = alloc_status(1))
        ALLOCATE(wpte(4*mnqpte,nel_type),STAT = alloc_status(2))
      ENDIF



      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_qpt_arrays"
          PRINT*, "Stage = ", stage
          STOP
        ENDIF
      ENDDO

      RETURN
      END SUBROUTINE alloc_qpt_arrays


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE alloc_basis_arrays()

      USE globals, ONLY: phia,phia_int,phia_int_init, &
                         dpdr,dpds,dpdx,dpdx_init,dpdy,dpdy_init, &
                         phie,phie_int, &
                         phil, &
                         dhbdx,dhbdx_init,dhbdy,dhbdy_init

      IMPLICIT NONE
      INTEGER, PARAMETER :: n=6
      INTEGER :: alloc_status(n)
      INTEGER :: i

      alloc_status(:) = 0


      ! Basis function arrays for area quadrature points
      ALLOCATE(phia(mndof,mnqpta,nel_type),phia_int(ne,mndof,mnqpta),phia_int_init(ne,mndof,mnqpta),STAT = alloc_status(1))

      ! Basis function derivative arrays for area quadrature points
      ALLOCATE(dpdr(mndof,mnqpta,nel_type),dpds(mndof,mnqpta,nel_type),STAT = alloc_status(2))
      ALLOCATE(dpdx(ne,mndof,mnqpta),dpdy(ne,mndof,mnqpta),STAT = alloc_status(3))
      ALLOCATE(dpdx_init(ne,mndof,mnqpta),dpdy_init(ne,mndof,mnqpta),STAT = alloc_status(4))

      ! Basis function arrays for edge quadrature points
      ALLOCATE(phie(mndof,4*mnqpte,nel_type),phie_int(mndof,4*mnqpte,nel_type),STAT = alloc_status(5))

      ! Linear nodal basis functions for triangles
      ALLOCATE(phil(3,mnqpta,nel_type),STAT = alloc_status(6))

      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_basis_arrays"
          STOP
        ENDIF
      ENDDO

      RETURN
      END SUBROUTINE alloc_basis_arrays

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE alloc_trans_arrays()

      USE globals, ONLY: dhbdx,dhbdx_init,dhbdy,dhbdy_init, &
                         hbqpta,hbqpta_init,hbqpte,hbqpte_init,hbqpted, &
                         psia,dpsidr,dpsids,psiv,psic, &
                         detJa,mmi,mmi_init, &
                         nx_pt,ny_pt,cfac,Spe, &
                         psie,dpsidxi,detJe, &
                         area,edlen,edlen_area,normal

      IMPLICIT NONE
      INTEGER, PARAMETER :: n=14
      INTEGER :: alloc_status(n)
      INTEGER :: i

      alloc_status(:) = 0

      ! Bathymetry derivatives
      ALLOCATE(dhbdx(ne,mnqpta),dhbdy(ne,mnqpta),STAT = alloc_status(1))
      ALLOCATE(dhbdx_init(ne,mnqpta),dhbdy_init(ne,mnqpta),STAT = alloc_status(2))

      ! Bathymetry evaluated at quadrature points
      ALLOCATE(hbqpta_init(ne,mnqpta),hbqpta(ne,mnqpta), STAT = alloc_status(3))
      ALLOCATE(hbqpte_init(ne,4*mnqpte),hbqpte(ne,4*mnqpte),hbqpted(ned,mnqpte), STAT = alloc_status(4))

      ! Area transformation information
      ALLOCATE(psia(mnnds,mnqpta+4*mnqpte,2*nel_type),STAT = alloc_status(5))
      ALLOCATE(dpsidr(mnnds,mnqpta+4*mnqpte,2*nel_type),dpsids(mnnds,mnqpta+4*mnqpte,2*nel_type),STAT = alloc_status(6))
      ALLOCATE(detJa(ne,mnqpta),mmi_init(ne,mndof*mndof),mmi(ne,mndof*mndof),STAT = alloc_status(7))
      ALLOCATE(nx_pt(ned,mnqpte),ny_pt(ned,mnqpte),cfac(ned,mnqpte),Spe(ned,mnqpte),STAT = alloc_status(8))
      ALLOCATE(psiv(mnnds,mnnds,norder),psic(mnnds,mnnds,norder),STAT = alloc_status(9))

      ! Edge transformation information
      ALLOCATE(psie(mnp,mnqpte,norder),dpsidxi(mnp,mnqpte,norder),STAT = alloc_status(10))
      ALLOCATE(detJe(ned,mnqpte),STAT = alloc_status(11))

      ! Depreciated arrays, used as a check
      ALLOCATE(area(ne),STAT = alloc_status(12))
      ALLOCATE(edlen(ned),edlen_area(2,ned),STAT = alloc_status(13))
      ALLOCATE(normal(2,ned),STAT = alloc_status(14))

      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_trans_arrays"
          STOP
        ENDIF
      ENDDO

      RETURN
      END SUBROUTINE alloc_trans_arrays

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE alloc_sol_arrays()

      USE globals, ONLY: H,Hold,Hinit,rhsH, &
                         Z,Zold,Zinit,rhsZ, &
                         Qx,Qxold,Qxinit,rhsQx, &
                         Qy,Qyold,Qyinit,rhsQy, &
                         Hqpt,Zqpt,Qxqpt,Qyqpt,xmom,ymom,xymom, &
                         Hqpta,Zqpta,Qxqpta,Qyqpta,xmoma,ymoma,xymoma, &
                         tau,src_x,src_y,recipHa, &
                         MirhsH,MirhsZ,MirhsQx,MirhsQy, &
                         Hwrite,Zwrite,Qxwrite,Qywrite, &
                         Exx,Eyy,Exy,Eyx, &
                         Exxqpt,Eyyqpt,Exyqpt,Eyxqpt, &
                         Exxqpta,Eyyqpta,Exyqpta,Eyxqpta, &
                         rhsExx,rhsEyy,rhsExy,rhsEyx


      IMPLICIT NONE
      INTEGER, PARAMETER :: n=16
      INTEGER :: alloc_status(n)
      INTEGER :: i

      alloc_status(:) = 0

      mnelred = MAX(ne,nred)


      ! Solution arrays
      ALLOCATE(Hinit(ne,mndof),Zinit(ne,mndof),Qxinit(ne,mndof),Qyinit(ne,mndof),STAT = alloc_status(1))
      ALLOCATE(H(ne,mndof),Z(ne,mndof),Qx(ne,mndof),Qy(ne,mndof),STAT = alloc_status(2))

      ! Old solution arrays
      ALLOCATE(Hold(ne,mndof),Zold(ne,mndof),Qxold(ne,mndof),Qyold(ne,mndof),STAT = alloc_status(3))

      ! RHS arrays
      ALLOCATE(rhsH(ne,mndof),rhsZ(ne,mndof),rhsQx(ne,mndof),rhsQy(ne,mndof),STAT = alloc_status(4))
      ALLOCATE(MirhsH(ne,mndof),MirhsZ(ne,mndof),MirhsQx(ne,mndof), MirhsQy(ne,mndof),STAT = alloc_status(5))

      ! Evaluation Arrays
      ALLOCATE(Hqpta(ne),Zqpta(ne),Qxqpta(ne),Qyqpta(ne), STAT = alloc_status(6))
      ALLOCATE(xmoma(ne),ymoma(ne),xymoma(ne), STAT = alloc_status(7))
      ALLOCATE(Hqpt(ne,4*mnqpte),Zqpt(ne,4*mnqpte),Qxqpt(ne,4*mnqpte),Qyqpt(ne,4*mnqpte),STAT = alloc_status(8))
      ALLOCATE(xmom(ne,4*mnqpte),ymom(ne,4*mnqpte),xymom(ne,4*mnqpte),STAT = alloc_status(9))
      ALLOCATE(recipHa(mnelred),STAT = alloc_status(10))

      ! Source term arrays
      ALLOCATE(tau(ne),src_x(ne),src_y(ne),STAT = alloc_status(11))


      ! Write arrays
      ALLOCATE(Hwrite(ne,mndof),Zwrite(ne,mndof),Qxwrite(ne,mndof),Qywrite(ne,mndof),STAT = alloc_status(12))

      ! LDG arrays
      ALLOCATE(Exx(ne,mndof),Eyy(ne,mndof),Exy(ne,mndof),Eyx(ne,mndof),STAT = alloc_status(13))
      ALLOCATE(Exxqpta(ne),Eyyqpta(ne),Exyqpta(ne),Eyxqpta(ne), STAT = alloc_status(14))
      ALLOCATE(Exxqpt(ne,4*mnqpte),Eyyqpt(ne,4*mnqpte),Exyqpt(ne,4*mnqpte),Eyxqpt(ne,4*mnqpte),STAT = alloc_status(15))
      ALLOCATE(rhsExx(ne,mndof),rhsEyy(ne,mndof),rhsExy(ne,mndof),rhsEyx(ne,mndof),STAT = alloc_status(16))


      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_sol_arrays"
          STOP
        ENDIF
      ENDDO


      rhsZ(:,:) = 0d0
      rhsQx(:,:) = 0d0
      rhsQy(:,:) = 0d0

      MirhsZ(:,:) = 0d0
      MirhsQx(:,:) = 0d0
      MirhsQy(:,:) = 0d0

      rhsExx(:,:) = 0d0
      rhsEyy(:,:) = 0d0
      rhsExy(:,:) = 0d0

      Exx(:,:) = 0d0
      Eyy(:,:) = 0d0
      Exy(:,:) = 0d0

      Exxqpt(:,:) = 0d0
      Eyyqpt(:,:) = 0d0
      Exyqpt(:,:) = 0d0

      RETURN
      END SUBROUTINE alloc_sol_arrays

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      SUBROUTINE dealloc_init_arrays()

      USE globals, ONLY: Hinit,Zinit,Qxinit,Qyinit, &
                         dpdx_init,dpdy_init,phia_int_init, &
                         dhbdx_init,dhbdy_init,mmi_init


      IMPLICIT NONE
      INTEGER, PARAMETER :: n=5
      INTEGER :: alloc_status(n)
      INTEGER :: i

      alloc_status(:) = 0

      DEALLOCATE(Hinit,Zinit,Qxinit,Qyinit,STAT = alloc_status(1))
      DEALLOCATE(dpdx_init,dpdy_init, STAT = alloc_status(2))
      DEALLOCATE(phia_int_init, STAT = alloc_status(3))
      DEALLOCATE(dhbdx_init,dhbdy_init, STAT = alloc_status(4))
      DEALLOCATE(mmi_init, STAT = alloc_status(5))


      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Deallocation error: dealloc_init_arrays"
          STOP
        ENDIF
      ENDDO



      RETURN
      END SUBROUTINE dealloc_init_arrays

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

     SUBROUTINE alloc_ptr_arrays()

     USE globals, ONLY: Hi,He,Zi,Ze,Qxi,Qxe,Qyi,Qye, &
                        xmi,xme,ymi,yme,xymi,xyme, &
                        inx,iny,icfac,detJe_in,detJe_ex,const, &
                        Hhatv,Zhatv,Qxhatv,Qyhatv, &
                        Exxi,Exxe,Eyyi,Eyye,Exyi,Exye,Eyxi,Eyxe


     IMPLICIT NONE
     INTEGER, PARAMETER :: n=11
     INTEGER :: alloc_status(n)
     INTEGER :: i
     INTEGER :: npt

     alloc_status(:) = 0

     mnired  = MAX(nied,nred)
     npt = mnired*mnqpte

     ! Solution pointer arrays
     ALLOCATE(Hi(npt),He(npt),Zi(npt),Ze(npt), STAT=alloc_status(1))
     ALLOCATE(Qxi(npt),Qxe(npt),Qyi(npt),Qye(npt),STAT=alloc_status(2))
     ALLOCATE(xmi(npt),ymi(npt),xymi(npt),STAT=alloc_status(3))
     ALLOCATE(xme(npt),yme(npt),xyme(npt),STAT=alloc_status(4))


     ! Edge normals and jacobians
     ALLOCATE(inx(npt),iny(npt),icfac(npt),STAT=alloc_status(5))
     ALLOCATE(detJe_in(npt),detJe_ex(npt),STAT=alloc_status(6))

     ! Temporary storage arrays, LLF constant and fluxes
     ALLOCATE(const(npt),Hhatv(npt),Zhatv(npt),Qxhatv(npt),Qyhatv(npt),STAT=alloc_status(7))

     ! LDG pointer arrays
     ALLOCATE(Exxi(npt),Exxe(npt), STAT=alloc_status(8))
     ALLOCATE(Eyyi(npt),Eyye(npt), STAT=alloc_status(9))
     ALLOCATE(Exyi(npt),Exye(npt), STAT=alloc_status(10))
     ALLOCATE(Eyxi(npt),Eyxe(npt), STAT=alloc_status(11))

      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_ptr_arrays"
          STOP
        ENDIF
      ENDDO


     RETURN
     END SUBROUTINE alloc_ptr_arrays


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

     SUBROUTINE alloc_blk_arrays()

     USE globals, ONLY: npartel,gel2part,gel2lel,lel2gel,gel2ael, &
                        npartet,ael2gel,nparted,npartpt, &
                        edblk,nfblk,elblk,rnfblk

     IMPLICIT NONE
     INTEGER, PARAMETER :: n=11
     INTEGER :: alloc_status(n)
     INTEGER :: i

     alloc_status(:) = 0
      ALLOCATE(npartel(npart+1),STAT=alloc_status(1))
      ALLOCATE(gel2part(ne),gel2lel(ne),STAT=alloc_status(2))
      ALLOCATE(lel2gel(ne,npart+1),STAT=alloc_status(3))
      ALLOCATE(npartet(nel_type,npart+1),STAT=alloc_status(4))
      ALLOCATE(ael2gel(ne),gel2ael(ne),STAT=alloc_status(5))
      ALLOCATE(nparted(npart+1),STAT=alloc_status(6))
      ALLOCATE(npartpt(npart+1),STAT=alloc_status(7))
      ALLOCATE(edblk(2,npart),STAT=alloc_status(8))
      ALLOCATE(nfblk(2,npart+1),STAT=alloc_status(9))
      ALLOCATE(elblk(2,npart+1,nel_type),STAT=alloc_status(10))
      ALLOCATE(rnfblk(2,nrblk),STAT=alloc_status(11))

      DO i = 1,n
        IF (alloc_status(i) /= 0) THEN
          PRINT*, "Allocation error: alloc_blk_arrays"
          STOP
        ENDIF
      ENDDO



     RETURN
     END SUBROUTINE alloc_blk_arrays

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      END MODULE allocation
