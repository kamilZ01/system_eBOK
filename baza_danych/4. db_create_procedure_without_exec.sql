-------------------------------dodawanie użytkownika (sp_add_user)-----------------------------------
IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_add_user') DROP PROCEDURE sp_add_user
GO

CREATE PROCEDURE dbo.sp_add_user (
	@firstName VARCHAR(40),
	@lastName VARCHAR(40),
	@email VARCHAR(40),
	@password VARCHAR(30),
	@enabledAccount bit,
	@isBusinessAccount bit,
	@companyName VARCHAR(40),
	@taxId VARCHAR(11),
	@phoneNumber VARCHAR(15),
	@address VARCHAR(40),
	@zipCode VARCHAR(6),
	@city VARCHAR(25),
	@responseMessage VARCHAR(250) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		IF (LEN(@password) < 8)
			RAISERROR('Password should contain at least 8 characters.', 16, 1);
		INSERT INTO dbo.[user] (first_name, last_name, email, password_hash, enabled_account, is_business_account, company_name,
		tax_id, phone_number, address, zip_code, city)
		VALUES (@firstName, @lastName, @email, HASHBYTES('SHA2_512',@password), @enabledAccount, @isBusinessAccount, @companyName,
		@taxId, @phoneNumber, @address, @zipCode, @city);

		SET @responseMessage = 'Successfully added user.'
	END TRY
	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------edycja danych użytkownika z opcjonalnym polem (sp_edit_user)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_edit_user') DROP PROCEDURE sp_edit_user
GO

CREATE PROCEDURE dbo.sp_edit_user (
	@userId int,
	@firstName varchar(40) = NULL,
	@lastName varchar(40) = NULL,
	@email varchar(40) = NULL,
	@passwordHash binary(64) = NULL,
	@enabledAccount varchar(40) = NULL,
	@isBusinessAccount bit = NULL,
	@companyName varchar(40) = NULL,
	@taxId varchar(11) = NULL,
	@phoneNumber varchar(15) = NULL,
	@address varchar(40) = NULL,
	@zip_code varchar(6) = NULL,
	@city varchar(25) = NULL,
	@responseMessage varchar(250) OUTPUT)
AS 
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		UPDATE dbo.[user]
		SET first_name=ISNULL(@firstName, first_name),
			last_name=ISNULL(@lastName, last_name),
			email=ISNULL(@email, email),
			password_hash=ISNULL(HASHBYTES('SHA2_512',@passwordHash), password_hash),
			enabled_account=ISNULL(@enabledAccount, enabled_account),
			is_business_account=ISNULL(@isBusinessAccount, is_business_account),
			company_name=ISNULL(@companyName, company_name),
			tax_id=ISNULL(@taxId, tax_id),
			phone_number=ISNULL(@phoneNumber, phone_number),
			address=ISNULL(@address, address),
			zip_code=ISNULL(@zip_code, zip_code),
			city=ISNULL(@city, city)
		WHERE id_user = @userId
	END TRY 

	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------usuwanie użytkownika (sp_delete_user)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_delete_user') DROP PROCEDURE sp_delete_user
GO

CREATE PROCEDURE dbo.sp_delete_user (
	@userId int,
	@responseMessage varchar(250) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
	IF EXISTS (SELECT * FROM [user] WHERE id_user = @userId)
		BEGIN
			BEGIN TRY
				DELETE FROM [user]
				WHERE id_user = @userId
				SET @responseMessage = 'Successfully deleted user with ID = ' + CAST(@userId AS varchar(10));
			END TRY
			BEGIN CATCH
				SET @responseMessage = ERROR_MESSAGE()
			END CATCH
		END 
	ELSE
		BEGIN
			SET @responseMessage = 'There is no user with the given ID'
		END 
	SELECT @responseMessage
END
GO

-------------------------------dodawanie sprzętu (sp_add_hardware)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_add_hardware') DROP PROCEDURE sp_add_hardware
GO

CREATE PROCEDURE dbo.sp_add_hardware (
	@type varchar(40),
	@manufacturer varchar(40),
	@model varchar(40),
	@serialNumber varchar(40),
	@fee money,
	@responseMessage varchar(250) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		INSERT INTO dbo.hardware(type, manufacturer, model, serial_number, fee)
		VALUES (@type, @manufacturer, @model, @serialNumber,@fee)

		SET @responseMessage = 'Successfully added hardware.'

	END TRY
	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------edycja sprzętu z opcjonalnym polem (sp_edit_hardware)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_edit_hardware') DROP PROCEDURE sp_edit_hardware
GO

CREATE PROCEDURE dbo.sp_edit_hardware (
	@hardwareId int,
	@type varchar(40) = NULL,
	@manufacturer varchar(40) = NULL,
	@model varchar(40) = NULL,
	@serialNumber varchar(40) = NULL,
	@fee money = NULL,
	@responseMessage varchar(250) OUTPUT)
AS 
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		UPDATE dbo.hardware
		SET type=ISNULL(@type, type),
			manufacturer=ISNULL(@manufacturer, manufacturer),
			model=ISNULL(@model, model),
			serial_number=ISNULL(@serialNumber, serial_number),
			fee=ISNULL(@fee, fee)
		WHERE id_hardware = @hardwareId
	END TRY 

	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------usuwanie sprzętu (sp_delete_hardware)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_delete_hardware') DROP PROCEDURE sp_delete_hardware
GO

CREATE PROCEDURE dbo.sp_delete_hardware (
	@idHardware int,
	@responseMessage varchar(250) OUTPUT)

AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS (SELECT * FROM hardware WHERE id_hardware = @idHardware)
		BEGIN
			DELETE FROM hardware
			WHERE id_hardware = @idHardware
			SET @responseMessage = 'Successfully deleted hardware with ID = ' + CAST(@idHardware AS varchar(10));
		END
	ELSE
		BEGIN
			SET @responseMessage = 'There is no hardware with the given ID'
		END
	SELECT @responseMessage
END
GO

-------------------------------dodawanie usługi (sp_add_service)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_add_service') DROP PROCEDURE sp_add_service
GO

CREATE PROCEDURE dbo.sp_add_service (
	@name varchar(30),
	@fee money,
	@description varchar(300),
	@responseMessage varchar(250) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		INSERT INTO dbo.service(name, fee, description)
		VALUES (@name, @fee, @description)

		SET @responseMessage = 'Successfully added service.'
	END TRY

	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------edycja usługi z opcjonalnym polem (sp_edit_service)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_edit_service') DROP PROCEDURE sp_edit_service
GO
CREATE PROCEDURE dbo.sp_edit_service (
	@serviceId int,
	@name varchar(30) = NULL,
	@fee money = NULL,
	@description varchar(300) = NULL,
	@responseMessage varchar(250) OUTPUT)
AS 
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		UPDATE dbo.service
		SET name=ISNULL(@name, name),
			fee=ISNULL(@fee, fee),
			description=ISNULL(@description, description)
		WHERE id_service = @serviceId
	END TRY 

	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------usunięcie usługi (sp_delete_service)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_delete_service') DROP PROCEDURE sp_delete_service
GO

CREATE PROCEDURE dbo.sp_delete_service (
	@name varchar(30),
	@responseMessage varchar(250) OUTPUT)
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE @ifExists int = (select count(*) from service where name = @name)

	IF @name IS NULL OR @ifExists = 0
		BEGIN
			SET @responseMessage = 'There is no service with given name';
		END
	ELSE
	BEGIN TRY
		DELETE FROM service
		WHERE name = @name;
	END TRY 

	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------dodawanie faktury (sp_add_invoice)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_add_invoice') DROP PROCEDURE sp_add_invoice
GO

CREATE PROCEDURE dbo.sp_add_invoice (
	@clientId int,
	@expositorId int,
	@agreementId int,
	@invoiceNumber varchar(50),
	@issueDate date,
	@paymentDate date,
	@amount money,
	@responseMessage varchar(250) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS (SELECT * FROM agreement WHERE id_agreement = @agreementId)
	BEGIN
		BEGIN TRY
			INSERT INTO invoice
			VALUES (@clientId, @expositorId, @agreementId, @invoiceNumber, @issueDate, @paymentDate, @amount);
			SET @responseMessage = 'Successfully added invoice.'
		END TRY
		BEGIN CATCH
			SET @responseMessage=ERROR_MESSAGE()
		END CATCH
	END
	ELSE
		BEGIN
			SET @responseMessage = 'There is no agreement with the given ID.';
		END
	SELECT @responseMessage
END
GO

-------------------------------dodawanie korekty faktury (sp_add_invoice_correction)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_add_invoice_correction') DROP PROCEDURE sp_add_invoice_correction
GO

CREATE PROCEDURE dbo.sp_add_invoice_correction (
	@invoiceId int,
	@expositorId int,
	@invoiceCorrectionNumber varchar(50),
	@issueDate date,
	@paymentDate date,
	@amount money,
	@responseMessage varchar(250) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		IF NOT EXISTS(SELECT * FROM invoice where id_invoice = @invoiceId)
			RAISERROR('There is no invoice with the given ID', 16, 1);
		INSERT INTO invoice_correction 
		VALUES (@invoiceId, @expositorId, @invoiceCorrectionNumber, @issueDate, @paymentDate, @amount);

		SET @responseMessage = 'Successfully added invoice correction.'
	END TRY

	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------usuwanie faktury (sp_delete_invoice)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_delete_invoice') DROP PROCEDURE sp_delete_invoice
GO

CREATE PROCEDURE dbo.sp_delete_invoice (
	@invoiceId int,
	@responseMessage varchar(250) OUTPUT)

AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS (SELECT * FROM invoice WHERE id_invoice = @invoiceId)
		BEGIN
			BEGIN TRY
				DELETE FROM invoice
				WHERE id_invoice =  @invoiceId
				SET @responseMessage = 'Successfully deleted invoice with ID = ' + CAST(@invoiceId AS varchar(10));
			END TRY
			BEGIN CATCH
				SET @responseMessage = ERROR_MESSAGE()
			END CATCH
		END 
	ELSE
		BEGIN
			SET @responseMessage = 'There is no invoice with the given ID'
		END 
	SELECT @responseMessage
END
GO

-------------------------------dodawanie ticketu (sp_add_ticket)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_add_ticket') DROP PROCEDURE sp_add_ticket
GO

CREATE PROCEDURE dbo.sp_add_ticket (
	@idUser int,
	@topic varchar(50),
	@message varchar(500),
	@createdDate datetime,
	@idStatus int,
	@responseMessage varchar(250) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		INSERT INTO dbo.ticket (id_user, topic, message, created_date, id_status)
		VALUES (@idUser, @topic, @message, @createdDate, @idStatus)

		SET @responseMessage = 'Successfully added ticket.'

	END TRY
	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO

-------------------------------dodawanie odpowiedzi na ticket (sp_add_response_to_ticket)-----------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='P'
AND NAME='sp_add_response_to_ticket') DROP PROCEDURE sp_add_response_to_ticket
GO

CREATE PROCEDURE dbo.sp_add_response_to_ticket (
	@idTicket int,
	@idUser int,
	@responseDate datetime,
	@message varchar(500),
	@responseMessage varchar(250) OUTPUT)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		INSERT INTO dbo.response_to_ticket (id_ticket, id_user, response_date, message)
		VALUES (@idTicket, @idUser, @responseDate, @message)

		SET @responseMessage = 'Successfully added response to ticket.'

	END TRY
	BEGIN CATCH
		SET @responseMessage=ERROR_MESSAGE()
	END CATCH
	SELECT @responseMessage
END
GO