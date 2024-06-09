use master

if DB_ID ('HospitalManagementDB') is not null
drop database HospitalManagementDB 

declare @data_path varchar(256)
set @data_path=(Select SUBSTRING(physical_Name,1, Charindex(N'Master.mdf', lower(physical_name))-1)
				from master.sys.master_files
				where database_id=1 and file_id=1)
Execute ('create database HospitalManagementDB on primary (Name=HospitalManagementDB_Data, FileName='''+@data_path+'HospitalManagementDB_Data.mdf'', size=30MB, maxsize=unlimited, filegrowth=10%)
		 log on (Name=HospitalManagementDB_log, FileName='''+@data_path+'HospitalManagementDB_log.ldf'', size=10MB, maxsize=100MB, filegrowth=5%)')
go


--=============================================================================
							---CREATE SCHEMA---
--==============================================================================

create schema hms
go
--=============================================================================
							---CREATE TABLE---
--==============================================================================

use HospitalManagementDB
Create Table hms.Patient
(
PatientID int primary key identity(100,1),
Patient_Name varchar(30) not null,
[Address] varchar(50),
Contact_Number nvarchar(15) not null,
Gender Varchar(10) not null,
Age nvarchar(3) not null,
Disease varchar(100) not null
)
go

use HospitalManagementDB
create Table hms.Department
(
DepID int Primary key identity (1,1),
Dep_Name varchar(30) not null
)
go
	
use HospitalManagementDB
create Table hms.Employers
(
EmpID int primary key identity(1,1),
Employer_Name varchar(30) not null,
Address varchar(50),
Contact_Number nvarchar(15) not null,
Gender Varchar(10) not null,
Joining_date Date not null,
DepID int foreign key references hms.Department(DepID)
)
go

use HospitalManagementDB
Create Table hms.Specialization 
(
Spe_Code int Primary key identity(1,1),
Specialize varchar(30) not null
)
go

use HospitalManagementDB
create table hms.DoctorSpecialize
(
EmpID int foreign key references hms.Employers(EmpID),
Spe_Code int Foreign key references hms.Specialization(Spe_Code)
)
go

use HospitalManagementDB
Create Table hms.OutdoorPatient
(
PatientID int foreign key references hms.Patient(PatientID),
DoctorID int foreign key references hms.Employers(EmpID),
DrVisit_Fee decimal (10,2),
AppointmentDate date
)
go

use HospitalManagementDB
create Table hms.TreatementRecord
(
TreatmentID int primary key identity(1,1),
EmpID int foreign key references hms.Employers(EmpID),
PatientID int foreign key references hms.Patient(PatientID),
Treatment_Name varchar(50)
)
go


use HospitalManagementDB
create Table hms.Rooms
(
RoomNo int primary key identity(201,1),
Room_Type varchar(30),
Per_Day_Cost int
)
go


use HospitalManagementDB
Create Table hms.IndoorPatient
(
AdmitID int primary key identity(1,1),
PatientID int foreign key references hms.Patient(PatientID),
Admited_Doctor int foreign key references hms.Employers(EmpID),
Room_Number int foreign key references hms.Rooms(RoomNo),
Date_Of_Admission Date,
)
go


create Table hms.MedicalServices
(
MediServiceID int PRIMARY KEY identity(1,1),
Service_Name varchar(50) not null,
Service_Fee int
)
go


create Table hms.Invoice
(
InvoiceID int primary key identity(1,1),
PatientID int foreign key references hms.Patient(patientID),
ServiceEntryID int,
MediServiceID int foreign key references  hms.MedicalServices(MediServiceID),
Quantity INT NOT NULL,
UnitPrice DECIMAL(10, 2) NOT NULL,
Total DECIMAL(10, 2) NOT NULL,
Entry_Date Date,
)
go

create table hms.CorrectionPatientInfo
(
Serial int identity(1,1),
PatientID int foreign key references hms.Patient(PatientID),
[Address] varchar(50),
Contact_Number nvarchar(15),
Gender Varchar(10),
Age nvarchar(3),
Disease varchar(100),
ActionName varchar(30),
ActionTime datetime
)
go

select * from hms.CorrectionPatientInfo

--=============================================================================
							---ALTER TABLE---
--==============================================================================

select * from hms.patient

----ADD COLUMN
Alter Table hms.patient
Add Remark varchar(30)

----DELETE COLUMN
Alter Table hms.patient
drop column remark

--======================================================================
---------------------------------DROP TABLE-----------------------------------
--======================================================================

Drop table hms.Patient

--=============================================================================
				---CLUSTERED INDEX & NOT-CLUSTERED INDEX---
--==============================================================================
--Clustered
create clustered index c_emp on hms.MedicalServices(ServiceID)
go

----Non Clustered
create nonclustered index non_Emp on hms.Employers(Employer_Name)
go


--=============================================================================
				---View Encryption & Schemabinding ---
--==============================================================================

create view hms.Vw_patient
with encryption
as
	select PatientID, Patient_Name, Address, Contact_Number
	from hms.patient
go

create view hms.Vw_Emp
with Schemabinding
as
	select EmpID, Employer_Name, Contact_Number, Joining_Date
	from hms.Employers
go



--=============================================================================
				---Scalar Function, Tabular Function ---
--==============================================================================



----Tabular Function
create function fn_Patient
(
@patientid int
)
Returns Table
as 
	Return
	(Select * from hms.Patient where patientID=@patientid)

go



--=============================================================================
				---Store Procedure ---
--==============================================================================
----searchpatient SP
Create PROC sp_Searchpatient
@Name nvarchar(30)
AS
Select Patient_Name, [Address], Contact_Number, Gender , Age
From hms.Patient
Where Patient_Name like @Name +'%'  
GO

EXEC sp_Searchpatient ''



-----Insert
Create Procedure sp_insertPatient
(
@patient_Name varchar(30) ,
@address varchar(50),
@contact_Number nvarchar(15) ,
@gender Varchar(10) ,
@age nvarchar(3) ,
@disease varchar(100)
)
as
Begin
	declare @message varchar(30)
	Begin try
		insert into hms.Patient values (@patient_Name, @address ,@contact_Number  ,@gender ,@age ,@disease)
		set @message='Insert Successfully'
		Print @message 
	End try
	 
	Begin catch
		set @message='Insert failed '
		Print @message 
	End catch
	
End
GO


----Update
Create Procedure sp_UpdatePatient
(
@patient_Name varchar(30) ,
@address varchar(50),
@contact_Number nvarchar(15) ,
@gender Varchar(10) ,
@age nvarchar(3) ,
@disease varchar(100)
)
as
Begin
	declare @message varchar(30)
	Begin try
		declare @patientID int
		update hms.Patient
		set patient_Name=@patient_Name, address=@address, contact_Number=@contact_Number, gender=@gender, age=@age,disease=@disease
		Where PatientID=@patientID
		set @message='Update Successfully'
		Print @message 
	End try
	 
	Begin catch
		set @message='Update Failed'
		Print @message 
	End catch
	
End
GO


----Delete
Create Procedure sp_DeletePatient
(
@patientID int
)
as
Begin
	declare @message varchar(30)
	Begin try
		Delete from hmn.Patient
		Where PatientID=@patientID
		set @message='Delete Successfully'
		Print @message 
	End try
	 
	Begin catch
		set @message='Not Deleted'
		Print @message 
	End catch
	
End
go

--======================================================================
--------------------------------TRIGGER------------------------------
--======================================================================

create trigger trg_Patient on hms.Patient  
after insert,update, delete
as
begin
	declare @serial int, @patientID int ,@address varchar(50),@contact_Number nvarchar(15),
			@gender Varchar(10),@age nvarchar(3),@disease varchar(100),@actionName varchar(30),
			@actionTime datetime, @operation varchar(10)
	if exists (select * from deleted)
	Begin
		if exists (select * from inserted)
			begin
			set @operation='UPDATE'
			set @actionName='action fired'
			end
		ELSE
			SET @operation='DELETE'
	End
		ELSE
			SET @operation='INSERT'

		IF @operation='INSERT'
	BEGIN
		select @patientID=i.PatientID from inserted i; 
		select @address=i.address from inserted i; 
		select @contact_Number=i.contact_Number from inserted i; 
		select @gender=i.gender from inserted i; 
		select @age=i.age from inserted i; 
		select @disease=i.disease from inserted i; 
		
		set @actionname='Patient info insert or deleted'
		INSERT INTO hms.CorrectionPatientInfo values (@PatientID,@Address, @Contact_Number,@Gender ,@Age,@Disease,@ActionName ,GETDATE())
		Print 'Patient info insert or deleted'
	END
		else
	begin
		select @patientID=i.PatientID from deleted i; 
		select @address=i.address from deleted i; 
		select @contact_Number=i.contact_Number from deleted i; 
		select @gender=i.gender from deleted i; 
		select @age=i.age from deleted i; 
		select @disease=i.disease from deleted i; 
		
		set @actionname='◘◘Deleted Patient Info◘◘'
		INSERT INTO hms.CorrectionPatientInfo values (@PatientID,@Address, @Contact_Number,@Gender ,@Age,@Disease,@ActionName ,GETDATE())
		Print '◘◘Deleted Patient Info◘◘'
		
	end
end
go


--======================================================================
---------------------DROP TRIGGER---------------------------------------
--======================================================================

Drop  trigger trg_Patient on hms.Patient  

--======================================================================
---------------------Temporary Table ---------------------------------------
--======================================================================
--Local
Create table #tempTable1
(
ID int primary key identity(101,1),
Name varchar(30)
)
--Global
Create table ##tempTable2
(
ID int primary key identity(101,1),
Name varchar(30)
)
--======================================================================
---------------------MARGE---------------------------------------
--======================================================================

Merge #tempTable1 as Tb1
using ##tempTable2 as Tb2
on (Tb1.ID=Tb2.ID)
when Matched
	then Update set Tb1.Name=Tab2.Name
when Not Matched by target
	Then insert (Name) values (Tb1.Name)
when not matched by Source 
	then Delete;
go

--======================================================================
---------------------Temporary Variable Table -----------------------------------
--======================================================================
--LOCAL
declare @tempTable1
(
ID int primary key identity(101,1),
Name varchar(30)
)
--GLOBAL
declare @@tempTable1
(
ID int primary key identity(101,1),
Name varchar(30)
)

