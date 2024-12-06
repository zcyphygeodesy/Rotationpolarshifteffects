!  Rotapoleshifteffects.f90 
!
!  FUNCTIONS:
!  Rotapoleshifteffects - Entry point of console application.
!
!****************************************************************************

      program Rotapoleshifteffects
      implicit none
	character*800::line,str,astr,stm
	integer i,j,k,NUM,nn,IY,IM,ID,ih,imn,kk,sn,knd,kln,ka,kb
      real*8 tim,sec,rec(800),rs,pi,RAD,da,db,m1,m2
	real*8 GRS(6),eop(80000,6),tdn(24),BLH(3),tmp,tm,td,fd,mjd,mjd01,mjd02
	real*8 tm1,tm2,mjd1,mjd2,tdn0(14)
	real*8 plon, plat, phgt, bgntm, endtm, tmdlt,ltm
	integer::status=0
!---------------------------------------------------------------------
      GRS(1)= 3.986004415d14; GRS(2)=6378137.d0; GRS(3)=1.0826359d-3
      GRS(4) = 7.292115d-5; GRS(5)=1.d0/298.25641153d0
      pi=datan(1.d0)*4.d0; RAD=pi/180.d0;rs=1.d0/36.d2*RAD
      !Input longitude (degree decimal), latitude (degree decimal), ellipsoidal height (m) 
      !输入经纬度大地高
	plon=121.24d0; plat=29.4281; phgt=17.830
      !Input starting time (long integer time), ending time, time interval (minute) 输入起止时间与时间间隔
      bgntm=20180101;endtm=20200101; tmdlt=240.d0/1440.d0
 	!Read IERS EOP file IERSeopc04.dat
      !MJD(day);EOP(i,1:6)= x(") y(") UT1-UT(s) LOD(s) dX(") dY(")
      open(unit=8,file="IERSeopc04.dat",status="old",iostat=status)
      if(status/=0) goto 902 
      do i=1,14
         read(8,'(a)') line
      enddo
	i=1
      do while(.not.eof(8))  
         read(8,'(a)') line
         call PickRecord(line,kln,rec,sn)
         if(sn<8)goto 407
         tm=rec(4);eop(i,1:6)=rec(5:10)
	   if(i==1)tm1=tm
         i=i+1
407      continue
	enddo
903   close(8)
      tm2=tm
      !Transform the long integer time (date) agreed by ETideLoad to year, month, day, hour, minute and second
      !ETideLoad格式日期tm转年月日时分秒。
      call tmcnt(bgntm,IY,IM,ID,ih,imn,sec)
      !Gregorian Calendar to Julian Date.
      call CAL2JD (IY,IM,ID,mjd,j)
      mjd01=mjd+dble(ih)/24.d0+dble(imn)/1440.d0+dble(sec)/864.d2 !GPS_MJD
      call tmcnt(endtm,IY,IM,ID,ih,imn,sec)
      call CAL2JD (IY,IM,ID,mjd,j)
      mjd02=mjd+dble(ih)/24.d0+dble(imn)/1440.d0+dble(sec)/864.d2 !GPS_MJD
      if(mjd02<mjd01)goto 902
      open(unit=10,file='reslt.txt',status="replace") !Output file 输出文件
      BLH(1)=plat;BLH(2)=plon;BLH(3)=phgt
      write(10,'(a8,2F12.6,F10.3,F15.6)')'calcpnt',plon,plat,phgt,mjd01
      mjd=mjd01;mjd02=mjd02+1.d-6;k=0
      do while(mjd<mjd02)
         !Interpolate rotation polar shift parameters at mjd epoch time
         !内插mjd历元时刻极移参数
         tdn(1:14)=0.d0;fd=mjd-tm1+1.d0
         ka=nint(fd-.5d0); kb=nint(fd+.5d0)
         da=fd-dble(ka)+1.d-8; db=dble(kb)-fd+1.d-8
         m1=(eop(ka,1)/da+eop(kb,1)/db)/(1.d0/da+1.d0/db)
         m2=-(eop(ka,2)/da+eop(kb,2)/db)/(1.d0/da+1.d0/db)
         !Calculate the rotation polar shift effects on all-element geodetic variations
         call PoleCalc(BLH,m1*rs,m2*rs,tdn,GRS)
         tdn(11)=tdn(10)-tdn(1)  !orthometric height variation（mm）
         tdn(12:14)=tdn(12:14)*1.d1
         if(k<1)tdn0(1:14)=tdn(1:14)
         call mjdtotm(mjd,ltm)
         call tmtostr(ltm,stm)
         write(10,'(a15,F12.6,40F12.4)')adjustl(stm), mjd-mjd01, (tdn(i)-tdn0(i),i=1,14)
         mjd=mjd+tmdlt;k=k+1
906      continue
	enddo
      close(10)
902	continue
101   format(a,40F12.4)
      write (*,*)'  Complete the computation! The results are saved in the file reslt.txt.'
      pause
      end

