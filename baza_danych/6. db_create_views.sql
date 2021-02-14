-- Widok faktur z wybranymi danymi klienta oraz informacją czy dana faktura została opłacona
-- (invoices_with_client_and_payment_info_view)

IF OBJECT_ID(N'dbo.invoices_with_client_and_payment_info_view', N'V') IS NOT NULL
DROP VIEW invoices_with_client_and_payment_info_view
GO

CREATE VIEW dbo.invoices_with_client_and_payment_info_view AS
SELECT i.id_invoice, i.invoice_number, u.first_name + ' ' + u.last_name AS 'Client', 
ux.first_name + ' ' + ux.last_name AS 'Expositor', i.issue_date, i.payment_date, amount, dbo.fn_check_invoice_payments(i.id_invoice) AS 'Invoice Payment Status'
FROM dbo.invoice i JOIN [user] u ON i.id_client = u.id_user
JOIN [user] ux ON i.id_expositor = ux.id_user
GO

SELECT * from invoices_with_client_and_payment_info_view


-- Widok sprzętów z informacją o kliencie który aktualnie posiada dany sprzęt
-- (hardware_with_client_info_view)
IF OBJECT_ID(N'dbo.hardware_with_client_info_view', N'V') IS NOT NULL
DROP VIEW hardware_with_client_info_view
GO

CREATE VIEW dbo.hardware_with_client_info_view AS
SELECT  model, serial_number, u.first_name + ' ' + u.last_name AS 'Client',  u.address + '; ' + u.zip_code + '; ' +  u.city AS 'Address', 
u.phone_number FROM hardware h JOIN agreement_hardware ah ON h.id_hardware = ah.id_hardware 
JOIN agreement a ON ah.id_agreement = a.id_agreement JOIN [user] u ON a.id_user = u.id_user
WHERE a.start_date <= GETDATE() AND a.end_date >= GETDATE()
GO

SELECT * FROM hardware_with_client_info_view


-- Widok ticketów wraz z wszystkimi odpowiedziami
-- (tickets_with_all_responses)
IF OBJECT_ID(N'dbo.tickets_with_all_responses', N'V') IS NOT NULL
DROP VIEW tickets_with_all_responses
GO

CREATE VIEW dbo.tickets_with_all_responses AS
SELECT t.message AS 'ticket', t.created_date, rtt.message as 'response', rtt.response_date 
FROM response_to_ticket rtt join ticket t ON rtt.id_ticket = t.id_ticket
GO

SELECT * FROM tickets_with_all_responses

-- Widok klientów wraz z informacją odnośnie ich bilansu konta oraz sumie wydanych pieniędzy na zapłacenie faktur
-- (clients_with_info_about_account_balance_and_total_paid_amount)
IF OBJECT_ID(N'dbo.clients_with_info_about_account_balance_and_total_paid_amount', N'V') IS NOT NULL
DROP VIEW clients_with_info_about_account_balance_and_total_paid_amount
GO

CREATE VIEW dbo.clients_with_info_about_account_balance_and_total_paid_amount AS
SELECT u.first_name + ' ' + u.last_name AS 'Client', u.account_balance, SUM(p.amount) AS 'In total_paid'
FROM [user] u JOIN invoice i ON u.id_user = i.id_client JOIN payment p ON i.id_invoice = p.id_invoice
WHERE dbo.fn_check_user_role(u.id_user, 'klient') = 1 GROUP BY u.first_name, u.last_name, u.account_balance
 
GO

SELECT * FROM dbo.clients_with_info_about_account_balance_and_total_paid_amount
