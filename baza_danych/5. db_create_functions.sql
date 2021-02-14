-- Funkcja sprawdzająca czy określony sprzęt jest dostępny 
-- (fn_check_hardware_available)

IF EXISTS(SELECT 1 FROM sys.objects WHERE TYPE='FN'
AND NAME='fn_check_hardware_available') DROP FUNCTION fn_check_hardware_available
GO

CREATE FUNCTION fn_check_hardware_available(@id_hardware int)
RETURNS bit AS
BEGIN
	IF NOT EXISTS(SELECT * FROM hardware WHERE id_hardware = @id_hardware)
		return 0
	DECLARE @num int = (SELECT COUNT(ah.id_hardware) FROM agreement_hardware ah JOIN agreement ag ON ah.id_agreement = ag.id_agreement WHERE ag.end_date > GETDATE() AND ah.id_hardware = @id_hardware)
	IF(@num > 0)
		return 0
	return 1
END
GO
select * from hardware
select * from agreement_hardware

select dbo.fn_check_hardware_available(3)

SELECT COUNT(ah.id_hardware) FROM agreement_hardware ah JOIN agreement ag ON ah.id_agreement = ag.id_agreement WHERE ag.end_date > GETDATE() AND ah.id_hardware = 3

-- Funkcja sprawdzająca czy dany użytkownik posiada określoną rolę
-- (fn_check_user_role)

IF OBJECT_ID(N'dbo.fn_check_user_role', N'FN') IS NOT NULL
	DROP FUNCTION fn_check_user_role;
GO

CREATE FUNCTION dbo.fn_check_user_role(@idUser int, @role varchar(30))
RETURNS BIT
AS
BEGIN
	DECLARE @returnValue int;
	SELECT @returnValue = COUNT(*) FROM [user] u JOIN user_role ur ON u.id_user = ur.id_user JOIN role r on ur.id_role = r.id_role 
	where u.id_user = @idUser AND r.name = @role;
	IF @returnValue > 0
		RETURN 1

	RETURN 0
END
GO

SELECT first_name, dbo.fn_check_user_role(id_user, 'delete hardware') from [user] where first_name = 'Hubert'

-- Funkcja sprawdzająca, ile razy określony klient zapłacił faktury po terminie 
-- (fn_check_invoices_paid_after_deadline)

IF OBJECT_ID(N'dbo.fn_check_invoices_paid_after_deadline', N'FN') IS NOT NULL
	DROP FUNCTION fn_check_invoices_paid_after_deadline;
GO

CREATE FUNCTION dbo.fn_check_invoices_paid_after_deadline(@idUser int)
RETURNS INT
AS
BEGIN
	DECLARE @returnValue int 
	SELECT @returnValue = COUNT(i.id_invoice) FROM dbo.invoice i join dbo.payment p on i.id_invoice = p.id_invoice 
	WHERE i.id_client = @idUser AND p.payment_date > i.payment_date AND p.status = 'completed'
	RETURN @returnValue
END
GO

SELECT dbo.fn_check_invoices_paid_after_deadline(2)

-- Funkcja sprawdzająca czy określona faktura została opłacona
-- (fn_check_invoice_payment_status)-----------------------------------

IF OBJECT_ID(N'dbo.fn_check_invoice_payment_status', N'FN') IS NOT NULL
	DROP FUNCTION fn_check_invoice_payment_status;
GO

CREATE FUNCTION dbo.fn_check_invoice_payment_status(@idInovice varchar(20))
RETURNS BIT
AS
BEGIN
	DECLARE @returnValue int;
	SELECT @returnValue = COUNT(*) FROM payment p JOIN invoice i ON p.id_invoice = i.id_invoice 
						  WHERE p.status = 'completed' AND i.invoice_number = @idInovice
	IF @returnValue > 0
		RETURN 1

	RETURN 0
END
GO

SELECT dbo.fn_check_invoice_payment_status(invoice_number) from invoice where id_invoice = 5

-- Funkcja sprawdzająca czy określone zgłoszenie zostało zamknięte
-- (fn_check_ticket_status)

IF OBJECT_ID(N'dbo.fn_check_ticket_status', N'FN') IS NOT NULL
	DROP FUNCTION fn_check_ticket_status
GO

CREATE FUNCTION dbo.fn_check_ticket_status(@ticketId int)
RETURNS BIT
AS 
BEGIN
	DECLARE @returnVaule int;
	SELECT @returnVaule = COUNT(t.id_ticket) FROM ticket t join status s on t.id_status = s.id_status where t.id_ticket = @ticketId AND s.name = 'closed'

	IF @returnVaule > 0
		RETURN 1

	RETURN 0
END
GO

SELECT dbo.fn_check_ticket_status(3)

-- Funkcja sprawdzająca, ile mamy podpisanych umów  w określonym zakresie dat (startDate, endDate)  
-- (fn_check_number_of_agreements_signed_in_given_period) 

IF OBJECT_ID(N'dbo.fn_check_number_of_agreements_signed_in_given_period', N'FN') IS NOT NULL
	DROP FUNCTION dbo.fn_check_number_of_agreements_signed_in_given_period;
GO

CREATE FUNCTION dbo.fn_check_number_of_agreements_signed_in_given_period(@startDate datetime, @endDate datetime)
RETURNS varchar(30)
AS
BEGIN
	IF(@endDate < @startDate)
		RETURN 'Invalid date range!';
	ELSE 
		DECLARE @quantity int;
		Set  @quantity = (select COUNT(id_agreement) as ile FROM agreement WHERE date_signed BETWEEN @startDate AND @endDate )

	RETURN  CAST(@quantity as varchar(30))
		
END
GO

select dbo.fn_check_number_of_agreements_signed_in_given_period('2020/11/20', '2021/01/25')

-- Funkcja sprawdzająca czy jest nadpłata/niedopłata faktury lub czy bilans jest równy 0 
-- (fn_check_invoice_payments)

IF OBJECT_ID(N'dbo.fn_check_invoice_payments', N'FN') IS NOT NULL
	DROP FUNCTION dbo.fn_check_invoice_payments;
GO

CREATE FUNCTION dbo.fn_check_invoice_payments(@invoiceNumber varchar(20))
RETURNS varchar(100)
AS
BEGIN
	DECLARE @balance money
	DECLARE @returnMess varchar(100)
	SELECT @balance = i.amount - SUM(p.amount) from payment p join invoice i on p.id_invoice = i.id_invoice where i.invoice_number = @invoiceNumber group by i.amount
	IF (@balance > 0)
		set @returnMess = 'Invoice no. ' + @invoiceNumber + ' was not completely paid. The remaining amount to be paid: ' + CAST(@balance as varchar(10))
	ELSE IF (@balance < 0)
		set @returnMess = 'Overpayment was made to the invoice no. ' + @invoiceNumber + ' . The overpayment amount: ' + CAST(ABS(@balance) as varchar(10))
	ELSE
		set @returnMess = 'The invoice was completely paid.'
	
	RETURN  @returnMess	
END
GO

SELECT dbo.fn_check_invoice_payments('FV-1/2020')