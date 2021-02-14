-- Ustawienie daty rejestracji użytkownika (user) po dodaniu go do bazy 
-- (tr_set_user_registration_date) 

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='TR'
AND NAME='tr_add_user_registration_date') DROP TRIGGER tr_add_user_registration_date
GO

CREATE TRIGGER tr_add_user_registration_date
ON dbo.[user]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON
	UPDATE dbo.[user]
	set registration_date = GETDATE()
	FROM dbo.[user] u join inserted i on i.id_user = u.id_user

END
GO

-- Aktualizacja bilansu (account_balance) klienta po dodaniu faktury
-- (tr_update_account_balance_after_add_invoice)

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='TR'
AND NAME='tr_update_account_balance_after_add_invoice') DROP TRIGGER tr_update_account_balance_after_add_invoice
GO

CREATE TRIGGER tr_update_account_balance_after_add_invoice
ON dbo.invoice
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON
	UPDATE dbo.[user]
	set account_balance = account_balance - i.amount
	FROM dbo.[user] ud join inserted i on i.id_client = ud.id_user
END
GO

-- Aktualizacja bilansu (account_balance) klienta po dodaniu korekty faktury
-- (tr_update_account_balance_after_add_invoice_correction)

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='TR'
AND NAME='tr_update_account_balance_after_add_invoice_correction') DROP TRIGGER tr_update_account_balance_after_add_invoice_correction
GO

CREATE TRIGGER tr_update_account_balance_after_add_invoice_correction
ON dbo.invoice_correction
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @id_client int = (SELECT inv.id_client from dbo.invoice inv join inserted i on inv.id_invoice = i.id_invoice)

	UPDATE dbo.[user]
	SET account_balance = account_balance + (Select inv.amount from dbo.invoice inv join inserted i on inv.id_invoice = i.id_invoice)
	FROM dbo.[user] 
	WHERE id_user = @id_client

	UPDATE dbo.[user]
	set account_balance = account_balance - i.amount
	FROM dbo.[user] ud join inserted i on @id_client = ud.id_user
END
GO

-- Aktualizacja bilansu (account_balance) klienta po aktualizacji statusu płatności na status 'completed'
-- (tr_update_account_balance_after_update_payment)

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='TR'
AND NAME='tr_update_account_balance_after_update_payment') DROP TRIGGER tr_update_account_balance_after_update_payment
GO

CREATE TRIGGER tr_update_account_balance_after_update_payment
ON dbo.payment
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON
	UPDATE dbo.[user]
	set account_balance = account_balance + i.amount
	FROM dbo.[user] ud join dbo.invoice inv on ud.id_user = inv.id_client join inserted i on i.id_invoice = inv.id_invoice
	WHERE i.status = 'completed'
END
GO

-- Ustawienie daty zamknięcia zgłoszenia na aktualną datę po zmianie statusu zgłoszenia na zamknięty
-- (tr_update_ticket_status_set_end_date)

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='TR'
AND NAME='tr_update_ticket_status_set_end_date') DROP TRIGGER tr_update_ticket_status_set_end_date
GO

CREATE TRIGGER tr_update_ticket_status_set_end_date
ON dbo.ticket
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON
	IF ((SELECT s.name FROM status s JOIN inserted i ON s.id_status = i.id_status) = 'closed')
		UPDATE dbo.ticket
		SET end_date = GETDATE()
		FROM dbo.ticket t join status s ON t.id_status = s.id_status JOIN inserted i on i.id_ticket = t.id_ticket
	ELSE 
		UPDATE dbo.ticket
		SET end_date = NULL
		FROM dbo.ticket t join status s ON t.id_status = s.id_status JOIN inserted i on i.id_ticket = t.id_ticket
END
GO

-- Podczas usuwania sprzętu, usuwane są powiązania danego sprzętu z umowami (agreement_hardware),
-- następnie sprzęt przenoszony jest do archiwum (hardware_archive) i na koniec usuwany jest sprzęt
-- (tr_delete_hardware) 

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='TR'
AND NAME='tr_delete_hardware') DROP TRIGGER tr_delete_hardware
GO

CREATE TRIGGER tr_delete_hardware
ON dbo.hardware
INSTEAD OF DELETE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE to_delete_hardware CURSOR FOR SELECT * from deleted
	DECLARE @id_hardware int, @type varchar(40), @manufacturer varchar(40), @model varchar(40), @serial_number varchar(40), @fee money
	open to_delete_hardware
	fetch next from to_delete_hardware into @id_hardware, @type, @manufacturer, @model, @serial_number, @fee
	IF(@@FETCH_STATUS = -1)
	BEGIN
		RAISERROR('No hardware to remove with the given ID. id_hardware = ', 11, 1)
		PRINT @@ERROR
	END
	ELSE
	BEGIN
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			INSERT INTO dbo.hardware_archive(id_hardware, type, manufacturer, model, serial_number, fee)
			VALUES(@id_hardware, @type, @manufacturer, @model, @serial_number, @fee)

			DELETE FROM dbo.agreement_hardware WHERE id_hardware = @id_hardware

			DELETE FROM dbo.hardware where id_hardware = @id_hardware
			fetch next from to_delete_hardware into @id_hardware, @type, @manufacturer, @model, @serial_number, @fee
		END
	END
	CLOSE to_delete_hardware
	deallocate to_delete_hardware
END
GO

-- Podczas usuwania powiązań sprzętu z umowami, powiązania są przenoszone do archiwum (agreement_hardware_archive)
-- (tr_move_agreement_hardware_to_archive) ----------------------------------------------

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='TR'
AND NAME='tr_move_agreement_hardware_to_archive') DROP TRIGGER tr_move_agreement_hardware_to_archive
GO

CREATE TRIGGER tr_move_agreement_hardware_to_archive
ON dbo.agreement_hardware
INSTEAD OF DELETE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE to_delete_agreement_hardware CURSOR FOR SELECT * from deleted
	DECLARE @id_agreement_hardware int, @id_agreement int, @id_hardware int
	open to_delete_agreement_hardware
	fetch next from to_delete_agreement_hardware into @id_agreement_hardware, @id_agreement, @id_hardware
	IF(@@FETCH_STATUS = -1)
	BEGIN
		RAISERROR('No hardware_agreement to remove with the given ID. id_hardware = ', 11, 1)
		PRINT @@ERROR
	END
	ELSE
	BEGIN
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			INSERT INTO dbo.agreement_hardware_archive(id_agreement_hardware, id_agreement, id_hardware)
			VALUES(@id_agreement_hardware, @id_agreement, @id_hardware)

			DELETE FROM dbo.agreement_hardware where id_agreement_hardware = @id_agreement_hardware
			fetch next from to_delete_agreement_hardware into @id_agreement_hardware, @id_agreement, @id_hardware
		END
	END
	CLOSE to_delete_agreement_hardware
	deallocate to_delete_agreement_hardware
END
GO