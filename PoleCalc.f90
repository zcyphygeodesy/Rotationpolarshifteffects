      subroutine PoleCalc(BLH,m1,m2,tdn,GRS)
      implicit none
	real*8::BLH(3),NFD(5),rln(3),m1,m2,tdn(24),GRS(6),gr
	integer n,m,kk,i,sp
	real*8 rr,rlat,rlon,pi,RAD,sta,GM,w,GM0,ae,h2,L2
	real*8 sin2s,cos2s,sins,coss
      complex*16 k21,mm,ela,ela2
!---------------------------------------------------------------------------
      pi=datan(1.d0)*4.d0; RAD=pi/180.d0;w=GRS(4);GM=GRS(1);ae=GRS(2)
      k21=(0.3077d0,0.0036d0);h2=0.6207;L2=0.0836;mm=cmplx(m1,m2)
      call GNormalfd(BLH,NFD,GRS);gr=NFD(2)
	call BLH_RLAT(GRS,BLH,rln);sta=pi/2.d0-rln(2)*RAD
	rr=rln(1);rlon=rln(3)*RAD
      sin2s=dsin(2.d0*sta);cos2s=dcos(2.d0*sta)
      sins=dsin(sta);coss=dcos(sta)
      ela=cmplx(dcos(rlon),dsin(rlon));ela2=cmplx(dcos(rlon-pi/2.d0),dsin(rlon-pi/2.d0))
      tdn(1)=dreal(-.5d0*w**2*ae**2/gr*(ae/rr)**3*(1.d0+k21)*mm*ela*sin2s) !高程异常）the geoid or height anomaly 
      tdn(2)=dreal(-1.5d0*w**2*ae*(ae/rr)**4*(1.d0-1.5d0*k21+h2)*mm*ela*sin2s)  !地面站点重力变化 ground gravity
      tdn(3)=dreal(-1.5d0*w**2*ae*(ae/rr)**4*(1.d0+k21)*mm*ela*sin2s)    !扰动重力变化 gravity disturbance
      tdn(4)=dreal(-w**2*ae/gr*(ae/rr)**4*(1.d0+k21-h2)*mm*ela*cos2s*sins) !地倾斜南向 vertical deflection S
      tdn(5)=dreal(-w**2*ae/gr*(ae/rr)**4*(1.d0+k21-h2)*mm*ela2*coss) !地倾斜西向 vertical deflection W
      tdn(6)=dreal(-w**2*ae/gr*(ae/rr)**4*(1.d0+k21)*mm*ela*cos2s*sins) !垂线偏差南向 vertical deflection S
      tdn(7)=dreal(-w**2*ae/gr*(ae/rr)**4*(1.d0+k21)*mm*ela2*coss) !垂线偏差西向 vertical deflection S
      tdn(8)=dreal(w**2*ae**2/gr*(ae/rr)**3*L2*mm*ela2*coss) !东方向 horizontal displacement E
      tdn(9)=dreal(w**2*ae**2/gr*(ae/rr)**3*L2*mm*ela*cos2s*sins) !北方向 horizontal displacement N
      tdn(10)=dreal(-.5d0*w**2*ae**2/gr*(ae/rr)**3*h2*mm*ela*sin2s) !地面站点大地高变化 ground radial displacement
      tdn(12)=dreal(-6.d0*w**2*(ae/rr)**5*(1.d0+k21)*mm*ela*sin2s)!扰动重力梯度径向 radial gravity gradient
      tdn(13)=dreal(2.d0*w**2*(ae/rr)**5*(1.d0+k21)*mm*ela*sin2s)!水平重力梯度北方向 horizontal gravity gradient N
      tdn(14)=dreal(-w**2*(ae/rr)**5*(1.d0+k21)*mm*ela*coss/sins)!水平重力梯度西方向 horizontal gravity gradient W
 	tdn(11)=tdn(10)-tdn(1)   
!--------------------------------------------------
      tdn(1)=tdn(1)*1.d3
	tdn(2:3)=tdn(2:3)*1.0e8
	tdn(4:7)=tdn(4:7)/RAD*36.d5
	tdn(8:10)=tdn(8:10)*1.d3
	tdn(12:14)=tdn(12:14)*1.d14 !0.01mE
	return
	end
