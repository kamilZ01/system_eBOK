USE [master];

DECLARE @kill varchar(8000) = '';  
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  = db_id('ebok')

EXEC(@kill);

if exists(select 1 from master.dbo.sysdatabases where name = 'ebok') drop database ebok
GO

CREATE DATABASE ebok
GO

CREATE TABLE ebok.dbo.hardware (
id_hardware int not null identity (1,1) PRIMARY KEY,
type varchar(40) not null,
manufacturer varchar(40) not null,
model varchar(40) not null,
serial_number varchar(40) not null unique,
fee money not null,
);
GO

CREATE TABLE ebok.dbo.hardware_archive (
id_hardware int,
type varchar(40),
manufacturer varchar(40),
model varchar(40),
serial_number varchar(40),
fee money,
);
GO

CREATE TABLE ebok.dbo.agreement_hardware_archive (
id_agreement_hardware int,
id_agreement int,
id_hardware int
);
GO

CREATE TABLE ebok.dbo.service (
id_service int not null identity (1,1) PRIMARY KEY,
name varchar(30) not null unique,
fee money not null,
description varchar(300)
);
GO

CREATE TABLE ebok.dbo.role (
id_role int not null identity (1,1) PRIMARY KEY,
name varchar(50) not null,
description varchar(150) null
);
GO

CREATE TABLE ebok.dbo.[user] (
id_user int not null identity (1,1) PRIMARY KEY,
first_name varchar(40) not null,
last_name varchar(40) not null,
email varchar(40) not null,
password_hash binary(64) not null,
enabled_account bit not null,
registration_date date null,
is_business_account bit not null,
company_name varchar (40) null,
tax_id varchar(11) not null,
phone_number varchar(15) not null,
address varchar(40) not null,
zip_code varchar(6) not null,
city varchar(25) not null,
account_balance money DEFAULT 0
);
GO

CREATE TABLE ebok.dbo.user_role (
id_user_role int not null identity (1,1) PRIMARY KEY,
id_user int not null,
id_role int not null,
constraint FKRoleUser foreign key (id_user) references [user](id_user),
constraint FKUserRole foreign key (id_role) references role(id_role)
);
GO

CREATE TABLE ebok.dbo.agreement (
id_agreement int not null identity (1,1) PRIMARY KEY,
agreement_type varchar(10) not null,
agreement_number varchar(25) not null,
creation_date date not null,
date_signed date null,
start_date date not null,
end_date date not null,
billing_day tinyint not null,
id_user int not null,
constraint FKAgreementUser foreign key (id_user) references [user](id_user),
);
GO

CREATE TABLE ebok.dbo.agreement_hardware (
id_agreement_hardware int not null identity (1,1) PRIMARY KEY,
id_agreement int not null,
id_hardware int not null,
constraint FKAgreementHardware foreign key (id_agreement) references agreement(id_agreement),
constraint FKHardwareAgreement foreign key (id_hardware) references hardware(id_hardware)
);
GO

CREATE TABLE ebok.dbo.agreement_service (
id_agreement_service int not null identity (1,1) PRIMARY KEY,
id_agreement int not null,
id_service int not null,
final_fee money not null,
constraint FKAgreementService foreign key (id_agreement) references agreement(id_agreement),
constraint FKServiceAgreement foreign key (id_service) references service(id_service)
);
GO

CREATE TABLE ebok.dbo.status (
id_status int not null identity (1,1) PRIMARY KEY,
name varchar(20) not null
)

CREATE TABLE ebok.dbo.ticket (
id_ticket int not null identity (1,1) PRIMARY KEY,
id_user int not null,
topic varchar(50) not null,
message varchar(500) not null,
created_date datetime not null,
end_date datetime default null,
id_status int not null,
constraint FKTicketUser foreign key (id_user) references [user](id_user),
constraint FKTicketStatus foreign key (id_status) references status(id_status)
);
GO

CREATE TABLE ebok.dbo.response_to_ticket (
id_response int not null identity (1,1) PRIMARY KEY,
id_ticket int not null,
id_user int not null,
response_date datetime not null,
message varchar(500) not null,
constraint FKResponseTicket foreign key (id_ticket) references ticket(id_ticket),
constraint FKResponseUser foreign key (id_user) references [user](id_user)
);
GO

CREATE TABLE ebok.dbo.invoice (
id_invoice int not null identity (1,1) PRIMARY KEY,
id_client int not null,
id_expositor int not null,
id_agreement int not null,
invoice_number varchar(50) not null,
issue_date date not null,
payment_date date not null,
amount money not null,
constraint FKInvoiceClient foreign key (id_client) references [user](id_user),
constraint FKInvoiceExpositor foreign key (id_expositor) references [user](id_user),
constraint FKInvoiceAgreement foreign key (id_agreement) references agreement(id_agreement),
);
GO

CREATE TABLE ebok.dbo.invoice_correction (
id_invoice_correction int not null identity (1,1) PRIMARY KEY,
id_invoice int not null,
id_expositor int not null,
invoice_correction_number varchar(50) not null,
issue_date date not null,
payment_date date not null,
amount money not null,
constraint FKInvoiceCorrectionInvoice foreign key (id_invoice) references [invoice](id_invoice),
constraint FKInvoiceCorrectionExpositor foreign key (id_expositor) references [user](id_user),
);
GO

CREATE TABLE ebok.dbo.payment (
id_payment int not null identity (1,1) PRIMARY KEY,
id_invoice int not null,
payment_date datetime not null,
amount money not null,
status varchar(20) not null,
constraint FKPaymentInvoice foreign key (id_invoice) references invoice(id_invoice),
);
GO

USE ebok;
GO