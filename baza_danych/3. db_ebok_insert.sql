
--administrator
INSERT INTO dbo.[user] (first_name, last_name, email, password_hash, enabled_account, is_business_account, tax_id, phone_number, address, zip_code, city) 
VALUES('Jan','Kowalczyk','jkowalczyk@gmail.com',HASHBYTES('SHA2_512','haslo12345'), 1, 0,'99892509874', '999777666', 'Prosta 10', '90-001', 'Łódź')

--pracownik
INSERT INTO dbo.[user] (first_name, last_name, email, password_hash, enabled_account, is_business_account, tax_id, phone_number, address, zip_code, city) 
VALUES('Wojciech','Zarębski','wzarebski@wp.pl',HASHBYTES('SHA2_512','1234578915'), 1, 0,'79896504874', '489587698', 'Malownicza 15A', '90-001', 'Łódź')

--klient
INSERT INTO dbo.[user] (first_name, last_name, email, password_hash, enabled_account, is_business_account, tax_id, phone_number, address, zip_code, city) 
VALUES('Anna','Nowak','anowak@wp.pl',HASHBYTES('SHA2_512','anka1234578915'), 1, 0,'89896504874', '689557698', 'Zarzewska 1/25', '90-001', 'Łódź')

--klient
INSERT INTO dbo.[user] (first_name, last_name, email, password_hash, enabled_account, is_business_account, company_name, tax_id, phone_number, address, zip_code, city) 
VALUES('Zbigniew','Kania','autonaprawakania@gmail.com',HASHBYTES('SHA2_512','autozda12345'), 1, 1, 'AUTO NAPRAWA Zbigniew Kania','6190013551', '799347666', 'Jana Kilińskiego 58', '95-200', 'Pabianice')

--klient
INSERT INTO dbo.[user] (first_name, last_name, email, password_hash, enabled_account, is_business_account, company_name, tax_id, phone_number, address, zip_code, city) 
VALUES('Jarosław','Łuczak','info@hydrowaz.pl',HASHBYTES('SHA2_512','hydrowaz123452021'), 1, 1, 'Hydrowąż s.c.','99892509874', '7312010905', 'Konopna 28', '95-200', 'Pabianice')

SELECT * FROM [user]

-----------------------------------------------------------------

INSERT INTO role VALUES('administrator', 'Zarządzanie systemem.');
INSERT INTO role VALUES('klient','Osoba korzystająca z usług firmy.');
INSERT INTO role VALUES('pracownik','Pracownik firmy.');

SELECT * FROM role

-----------------------------------------------------------------

INSERT INTO user_role VALUES(1,1)
INSERT INTO user_role VALUES(2,3)
INSERT INTO user_role VALUES(3,2)
INSERT INTO user_role VALUES(4,2)
INSERT INTO user_role VALUES(5,2)

SELECT * FROM user_role

-----------------------------------------------------------------

INSERT INTO status VALUES('open');
INSERT INTO status VALUES('in progress');
INSERT INTO status VALUES('closed');

SELECT * FROM status

-----------------------------------------------------------------

INSERT INTO ticket (id_user, topic, message, created_date,id_status) VALUES (3,'problem z podglądem faktury',
'Dzień dobry, mam problem z podglądem faktury, wyskakuje mi błąd, gdy chce ją pobrać. Proszę o pomoc.',
CAST(GETDATE() AS date), 1)

INSERT INTO ticket (id_user, topic, message, created_date,id_status) VALUES (4,'brak dostępnych usług',
'Dzień dobry, mam problem z wyświetleniem dostępnych usług. Proszę o pomoc.',GETDATE(), 1)

SELECT * FROM ticket

-----------------------------------------------------------------

INSERT INTO response_to_ticket VALUES (1,2,GETDATE(),
'Potrzebujemy trochę czasu, aby naprawić problem.')
INSERT INTO response_to_ticket VALUES (2,2,GETDATE(),
'Usługi są ponownie dostepne, przepraszamy za problem.')
INSERT INTO response_to_ticket VALUES (1,2,GETDATE(),
'Problem został rozwiązany, proszę o sprawdzenie czy teraz działa poprawnie.')

SELECT * FROM response_to_ticket

-----------------------------------------------------------------

UPDATE ticket SET id_status = 3 WHERE id_ticket = 1
UPDATE ticket SET id_status = 3 WHERE id_ticket = 2

SELECT * FROM ticket

-----------------------------------------------------------------

INSERT INTO hardware VALUES ('router','TP-LINK','TL-WR841N','12341234',19.99)
INSERT INTO hardware VALUES ('TV','PHILIPS','LED 58PUS8535/12','43214321',699.99)

SELECT * FROM hardware

-----------------------------------------------------------------

INSERT INTO service VALUES ('Net50',49.90,'Internet światłowodowy, prędkość pobierania: 50 Mb/s, prędkość wysyłania : 15 Mb/s')
INSERT INTO service VALUES ('TvMini',29.90,'Telewizja kablowa, pakiet mini, podstawowe kanały')

SELECT * FROM service

-----------------------------------------------------------------

INSERT INTO agreement VALUES('umowa','1/2020',CAST(GETDATE() AS date),CAST(GETDATE() AS date),CAST(GETDATE() AS date),CAST(DATEADD(YEAR,2,GETDATE()) AS date), 15, 3)
INSERT INTO agreement VALUES('umowa','2/2020',CAST(GETDATE() AS date),CAST(GETDATE() AS date),CAST(GETDATE() AS date),CAST(DATEADD(YEAR,1,GETDATE()) AS date), 22, 4)
INSERT INTO agreement VALUES('umowa','3/2020',CAST(GETDATE() AS date),CAST(GETDATE() AS date),CAST(GETDATE() AS date),CAST(DATEADD(YEAR,3,GETDATE()) AS date), 18, 5)

SELECT * FROM agreement

-----------------------------------------------------------------

INSERT INTO agreement_hardware VALUES (1,1)
INSERT INTO agreement_hardware VALUES (2,2)

SELECT * FROM agreement_hardware

-----------------------------------------------------------------

INSERT INTO agreement_service VALUES (1,1, 39.90)
INSERT INTO agreement_service VALUES (2,2, 24.90)

SELECT * FROM agreement_service

-----------------------------------------------------------------

INSERT INTO invoice VALUES(3,2,1,'FV-1/2020',CAST(GETDATE() AS date), CAST(DATEADD(DAY,5,GETDATE()) AS date),39.99)
INSERT INTO invoice VALUES(4,2,2,'FV-2/2020',CAST(GETDATE() AS date), CAST(DATEADD(DAY,3,GETDATE()) AS date),19.99)

SELECT * FROM invoice

-----------------------------------------------------------------

INSERT INTO invoice_correction VALUES(1,2,'FV-CORR-1/2020',CAST(GETDATE() AS date),CAST(DATEADD(DAY,2,GETDATE()) AS date),39.99)
INSERT INTO invoice_correction VALUES(2,2,'FV-CORR-2/2020',CAST(GETDATE() AS date),CAST(DATEADD(DAY,5,GETDATE()) AS date),29.99)

SELECT * FROM invoice_correction

-----------------------------------------------------------------

INSERT INTO payment VALUES(1,CAST(GETDATE() AS datetime), 39.99, 'pending')

SELECT * FROM payment

UPDATE payment SET status = 'completed' WHERE id_payment = 1

SELECT * FROM payment

-----------------------------------------------------------------
