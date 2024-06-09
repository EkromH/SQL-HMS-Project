--================================================================================================================
--                                       Select
--================================================================================================================
use HospitalManagementDB
select * from  hms.Patient
select * from hms.Department
select * from hms.Employers
select * from hms.Specialization 
select * from hms.DoctorSpecialize
select * from hms.OutdoorPatient
select * from hms.TreatementRecord
select * from hms.Rooms
select * from hms.IndoorPatient
select * from hms.MedicalServices
select * from hms.Invoice
select * from hms.CorrectionPatientInfo
go

--================================================================================================================
--                                       INSERT Table
--================================================================================================================
use HospitalManagementDB
insert into hms.Patient values 
('Khaleda', 'Sitakunda','01852','Female', '35','Fever, cough and shortness of breath'),
('Rahima', 'Sitakunda','01852','Female', '35','Osteoarthritis'),
('Sojib', 'Laxmipur','01963','Male', '25','mantal Health'),
('Monir', 'Dhaka','018633','Male', '35','BP')				
GO


use HospitalManagementDB
insert into hms.Department values 
('Doctor'),('Admin'),('Account')
go

use HospitalManagementDB
insert Into hms.Employers values 
('Asif','Ctg','019356','Male','01-01-2022',1),
('Sagor','Dhaka','015522','Male','05-04-2021',2),
('Lema','Feni','018866','Female','10-10-2020',1),
('Taposi','Shatkhira','017755','Female','01-02-2023',3),
('Jobaida','Comilla','019955','Female','05-03-2023',1)
go


insert into hms.Specialization values 
('Medicine'),('Orthopedics'),('Gyn & Obs'),('Cardiology'),('Diabetic')
go


insert into hms.DoctorSpecialize values 
										(1,1),
										(1,4),
										(3,3),
										(5,3),
										(5,5)
									
go


insert into hms.OutdoorPatient values
(102,1,1000,'01-01-2015'),
(101,1,1000,'10-10-2015'),
(100,5,1000,'10-11-2016'),
(102,5,1000,'11-09-2017'),
(103,1,1000,'12-01-2018'),
(101,1,1000,'09-05-2017'),
(102,5,1000,'12-07-2018')
go

use HospitalManagementDB
insert into hms.TreatementRecord values
(1,102,'Physical therapy'),
(1,101,'Lifestyle and dietary changes'),
(5,100,'Diabetes  diet exercise and medication management.'),
(3,102,'Long-acting reversible contraception.'),
(1,103,'Medications for heart conditions'),
(1,101,'Coronary artery bypass grafting (CABG)'),
(5,102,'Diabetes  diet exercise and medication management.')
go


insert into hms.Rooms values 
('General Bad', 600),
('Cabin Non-AC', 1500),
('Cabin AC',2000)
go

Insert into hms.Indoorpatient values
(101,3,201,'12-11-2023'),
(102,1,202,'10-11-2023')
go

insert into hms.MedicalServices values
('Oxygen',30),
('OT Charge',3000),
('Transport (Per KM)',80)
go



--================================================================================================================
--                                 Store Procedure Insert, Update, Delete RUN
--================================================================================================================

--Run Insert
Exec sp_insertPatient 'Monir','Ctg','01835962253','Male','25','Mental Helth' 
go

--Run UPdate
Exec sp_UpdatePatient 'Anowar','Ctg','01835962253','Male','25','Mental Helth' 
go

--Run Delete
Exec sp_DeletePatient '5' 
go

--================================================================================================================
--                                        VIEW Insert,Update,Delete
--================================================================================================================

---Insert
insert into hms.Vw_patient ( Patient_Name, Address, Contact_Number) values
						  ('Roman','Chattogram', '01833333333')

---Update
update hms.Vw_patient
set Patient_Name='Hamid'
Where PatientID=1

---Delete
Delete From hms.Vw_patient
where PatientID=1


--================================================================================================================
--                                        Distinct
--================================================================================================================

Select Distinct Patient_Name
from hms.Patients
go


--================================================================================================================
--                               Insert Into Copy table data From Another Table
--================================================================================================================

Select * 
into #tempTable1
From hmn.Patients
go

select * from #tempTable1


--================================================================================================================
--                                               Truncate Table
--================================================================================================================

Truncate Table #tempTable1 
go 

--================================================================================================================
--                                               QUERY
--================================================================================================================

------------Patient Total Service Record

select P.PatientID,P.Patient_Name, P.Address, P.Contact_Number, P.Gender, P.Age, P.Disease, emp.Employer_Name as Doctor_Name,s.Specialize, op.AppointmentDate, op.DrVisit_Fee
from hms.Patient p join hms.OutdoorPatient op
	on P.PatientID=op.PatientID
	join hms.Employers emp
	on op.EmpID=emp.EmpID
	join hms.DoctorSpecialize ds
	on emp.EmpID=ds.EmpID
	join hms.Specialization s
	on ds.Spe_Code=s.Spe_Code 
order by patientID Asc



------------Admited Patient Record
select *
from hms.Patient p join 


--================================================================================================================
--                                               JOIN
--================================================================================================================

---Left Join
select * 
from hms.Patient p
	left Join hms.IndoorPatient ip
	on P.PatientID=ip.PatientID
go

---Right Join
select * 
from hms.Patient p
	Right Join hms.IndoorPatient ip
	on P.PatientID=ip.PatientID
go

---Full Join
select * 
from hms.Employers emp
	 Full Join hms.DoctorSpecialize ds
	 on emp.EmpID=ds.EmpID
go

---Cross Join
select * 
from hms.Employers emp
	 Cross Join hms.DoctorSpecialize ds
go



--================================================================================================================
--                                         CUBE , ROLLUP & Grouping Set
--================================================================================================================

---CUBE
SELECT PatientId, COUNT(PatientId) AS TotalPatient
FROM hms.Patient
GROUP BY PatientId WITH CUBE
GO

---ROLLUP
SELECT PatientId, COUNT(PatientId) AS TotalPatient
FROM hms.Patient
GROUP BY PatientId WITH CUBE
GO


---Grouping Set
SELECT Patient_Name, COUNT(PatientId) AS TotalPatient
FROM hms.Patient
GROUP BY GROUPING sets (PatientId,Patient_Name)
GO


--================================================================================================================
--                                       Wildcard & Like
--================================================================================================================
SELECT * 
FROM hms.Patient
WHERE Patient_Name LIKE 'm%'
GO


 --================================================================================================================
--								           Floor & Chilling  
--================================================================================================================


DECLARE @test decimal (10,2)
SET @test = 11.75
SELECT ROUND(@test,-1)
SELECT ROUND(@test,1)	

