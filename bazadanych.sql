USE [master]
GO
/****** Object:  Database [Wypozyczalnia]    Script Date: 24.05.2018 11:04:17 ******/
CREATE DATABASE [Wypozyczalnia]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Wypozyczalnia', FILENAME = N'/var/opt/mssql/data/Wypozyczalnia.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Wypozyczalnia_log', FILENAME = N'/var/opt/mssql/data/Wypozyczalnia_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Wypozyczalnia] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Wypozyczalnia].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Wypozyczalnia] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET ARITHABORT OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Wypozyczalnia] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Wypozyczalnia] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Wypozyczalnia] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Wypozyczalnia] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET RECOVERY FULL 
GO
ALTER DATABASE [Wypozyczalnia] SET  MULTI_USER 
GO
ALTER DATABASE [Wypozyczalnia] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Wypozyczalnia] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Wypozyczalnia] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Wypozyczalnia] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Wypozyczalnia] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Wypozyczalnia', N'ON'
GO
ALTER DATABASE [Wypozyczalnia] SET QUERY_STORE = OFF
GO
USE [Wypozyczalnia]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [Wypozyczalnia]
GO
/****** Object:  User [pracownik1]    Script Date: 24.05.2018 11:04:17 ******/
CREATE USER [pracownik1] FOR LOGIN [\] WITH DEFAULT_SCHEMA=[db_pracownik]
GO
/****** Object:  User [kierownik]    Script Date: 24.05.2018 11:04:17 ******/
CREATE USER [kierownik] FOR LOGIN [\] WITH DEFAULT_SCHEMA=[db_accessadmin]
GO
/****** Object:  DatabaseRole [pracownik]    Script Date: 24.05.2018 11:04:18 ******/
CREATE ROLE [pracownik]
GO
ALTER ROLE [pracownik] ADD MEMBER [pracownik1]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [kierownik]
GO
/****** Object:  Schema [db_pracownik]    Script Date: 24.05.2018 11:04:18 ******/
CREATE SCHEMA [db_pracownik]
GO
/****** Object:  UserDefinedFunction [dbo].[KosztWypozyczenia]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[KosztWypozyczenia](@ID_produktu int, @ilDni int)
RETURNS int
AS
BEGIN
    DECLARE @total_wartosc MONEY;
    SELECT @total_wartosc = pp.CenaZaDobe*@ilDni
    FROM dbo.PelnyProdukt AS pp
    WHERE pp.ID = @ID_produktu;
     IF (@total_wartosc IS NULL)
        SET @total_wartosc = 0;
    RETURN @total_wartosc;
END
GO
/****** Object:  UserDefinedFunction [dbo].[KosztWypozyczeniaKaucja]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[KosztWypozyczeniaKaucja](@ID_produktu int, @ilDni int)
RETURNS int
AS
BEGIN
    DECLARE @total_wartosc MONEY;
    SELECT @total_wartosc = pp.CenaZaDobe*@ilDni + pp.Kaucja
    FROM dbo.PelnyProdukt AS pp
    WHERE pp.ID = @ID_produktu;
     IF (@total_wartosc IS NULL)
        SET @total_wartosc = 0;
    RETURN @total_wartosc;
END
GO
/****** Object:  Table [dbo].[PunktyObslugi]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PunktyObslugi](
	[IDPunktuObslugi] [int] IDENTITY(1,1) NOT NULL,
	[Ulica] [nvarchar](30) NOT NULL,
	[NrDomu] [nvarchar](10) NOT NULL,
	[Miasto] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IDPunktuObslugi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Klienci]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Klienci](
	[PESEL] [nvarchar](11) NOT NULL,
	[Imie] [nvarchar](30) NOT NULL,
	[Nazwisko] [nvarchar](30) NOT NULL,
	[SkanDowodu] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[PESEL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Produkty]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Produkty](
	[IDProduktu] [int] IDENTITY(1,1) NOT NULL,
	[Kategoria] [int] NULL,
	[Marka] [nvarchar](30) NOT NULL,
	[Model] [nvarchar](30) NOT NULL,
	[CenaZaDobe] [money] NOT NULL,
	[Kaucja] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IDProduktu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProduktySz]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProduktySz](
	[IDProduktuSZ] [int] IDENTITY(1,1) NOT NULL,
	[IDProduktu] [int] NULL,
	[IDPunktuObslugi] [int] NULL,
	[Stantechniczny] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IDProduktuSZ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Wypozyczenie]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Wypozyczenie](
	[IDWypozyczenia] [int] IDENTITY(1,1) NOT NULL,
	[DataWypozyczenia] [datetime2](7) NOT NULL,
	[DataDoZwrotu] [datetime2](7) NOT NULL,
	[DataZwrotu] [datetime2](7) NULL,
	[IDKlienta] [nvarchar](11) NULL,
	[IDPracWydajacego] [nvarchar](11) NULL,
	[IDPracOdbierajacego] [nvarchar](11) NULL,
PRIMARY KEY CLUSTERED 
(
	[IDWypozyczenia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WypozyczenieSz]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WypozyczenieSz](
	[IDWypozyczeniaSZ] [int] IDENTITY(1,1) NOT NULL,
	[IDWypozyczenia] [int] NULL,
	[IDProduktuSz] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDWypozyczeniaSZ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[WypozyczenieView]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WypozyczenieView] AS
  SELECT w.IDWypozyczenia AS ID,
    (k.Imie +' '+ k.Nazwisko) as Klient,
    DataWypozyczenia,
    DataDoZwrotu,
    DataZwrotu,
    (p.Marka +' '+ p.Model) as Narzędzie,
    (Obslugi.Miasto) as PunktObslugi,
    p.Kaucja,
    (p.CenaZaDobe * DATEDIFF(dd, DataWypozyczenia,DataDoZwrotu)) as Cena

  FROM Wypozyczenie w
    JOIN Klienci K ON w.IDKlienta = K.PESEL
    JOIN WypozyczenieSz S2 ON w.IDWypozyczenia = S2.IDWypozyczenia
    JOIN ProduktySz S3 ON S2.IDProduktuSz = S3.IDProduktuSZ
    JOIN Produkty P ON S3.IDProduktu = P.IDProduktu

  join PunktyObslugi Obslugi ON S3.IDPunktuObslugi = Obslugi.IDPunktuObslugi
GO
/****** Object:  Table [dbo].[Kategorie]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Kategorie](
	[IDKategorii] [int] IDENTITY(1,1) NOT NULL,
	[Nazwa] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IDKategorii] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[PelnyProdukt]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PelnyProdukt] AS (
  SELECT
    IDProduktuSZ AS ID,
    Marka,
    Model,
    CenaZaDobe,
    Kaucja,
    Nazwa        AS Kategoria,
    Miasto
  FROM Produkty P
    JOIN ProduktySz S2 ON P.IDProduktu = S2.IDProduktu
    JOIN Kategorie K ON P.Kategoria = K.IDKategorii
    JOIN PunktyObslugi Obslugi ON S2.IDPunktuObslugi = Obslugi.IDPunktuObslugi
)
GO
/****** Object:  Table [dbo].[Pracownicy]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pracownicy](
	[PESEL] [nvarchar](11) NOT NULL,
	[Imie] [nvarchar](30) NOT NULL,
	[Nazwisko] [nvarchar](30) NOT NULL,
	[Haslo] [nvarchar](30) NOT NULL,
	[DataZatrudnienia] [datetime2](7) NOT NULL,
	[IDPunktuObslugi] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[PESEL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rezerwacje]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rezerwacje](
	[IDRezerwacji] [int] IDENTITY(1,1) NOT NULL,
	[IDKlienta] [nvarchar](11) NULL,
	[DataRezerwacji] [datetime2](7) NOT NULL,
	[NaIleDni] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IDRezerwacji] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RezerwacjeSz]    Script Date: 24.05.2018 11:04:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RezerwacjeSz](
	[IDRezerwacjiSz] [int] IDENTITY(1,1) NOT NULL,
	[IDRezerwacji] [int] NULL,
	[IDProduktuSZ] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDRezerwacjiSz] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Kategorie] ON 

INSERT [dbo].[Kategorie] ([IDKategorii], [Nazwa]) VALUES (1, N'Wiertarki')
INSERT [dbo].[Kategorie] ([IDKategorii], [Nazwa]) VALUES (4, N'Szlifierki')
INSERT [dbo].[Kategorie] ([IDKategorii], [Nazwa]) VALUES (1002, N'Malowanie')
INSERT [dbo].[Kategorie] ([IDKategorii], [Nazwa]) VALUES (2002, N'Ogrodnicze')
SET IDENTITY_INSERT [dbo].[Kategorie] OFF
INSERT [dbo].[Klienci] ([PESEL], [Imie], [Nazwisko], [SkanDowodu]) VALUES (N'11111111111', N'Artur ', N'Ulfig', NULL)
INSERT [dbo].[Klienci] ([PESEL], [Imie], [Nazwisko], [SkanDowodu]) VALUES (N'12121212121', N'Maciej', N'Ślusarek', NULL)
INSERT [dbo].[Klienci] ([PESEL], [Imie], [Nazwisko], [SkanDowodu]) VALUES (N'123123', N'adsad', N'asdas', NULL)
INSERT [dbo].[Pracownicy] ([PESEL], [Imie], [Nazwisko], [Haslo], [DataZatrudnienia], [IDPunktuObslugi]) VALUES (N'0', N'Pracowmik', N'Prac', N'0', CAST(N'2018-04-19T10:12:00.1451998' AS DateTime2), 1)
INSERT [dbo].[Pracownicy] ([PESEL], [Imie], [Nazwisko], [Haslo], [DataZatrudnienia], [IDPunktuObslugi]) VALUES (N'1', N'Adam', N'Mitrega', N'1', CAST(N'2018-04-11T08:11:55.5966667' AS DateTime2), 1)
INSERT [dbo].[Pracownicy] ([PESEL], [Imie], [Nazwisko], [Haslo], [DataZatrudnienia], [IDPunktuObslugi]) VALUES (N'2', N'Olga', N'Nowak', N'2', CAST(N'2018-04-19T10:39:42.0336595' AS DateTime2), 1)
SET IDENTITY_INSERT [dbo].[Produkty] ON 

INSERT [dbo].[Produkty] ([IDProduktu], [Kategoria], [Marka], [Model], [CenaZaDobe], [Kaucja]) VALUES (2, 1, N'Bosch', N'BW1', 20.0000, 120.0000)
INSERT [dbo].[Produkty] ([IDProduktu], [Kategoria], [Marka], [Model], [CenaZaDobe], [Kaucja]) VALUES (1002, 4, N'DeWalt', N'DS1', 100.0000, 1200.0000)
INSERT [dbo].[Produkty] ([IDProduktu], [Kategoria], [Marka], [Model], [CenaZaDobe], [Kaucja]) VALUES (1003, 1002, N'Stanley', N'Pistolet1', 23.0000, 122.0000)
INSERT [dbo].[Produkty] ([IDProduktu], [Kategoria], [Marka], [Model], [CenaZaDobe], [Kaucja]) VALUES (1004, 1, N'DeWalt', N'DW1', 12.0000, 122.0000)
INSERT [dbo].[Produkty] ([IDProduktu], [Kategoria], [Marka], [Model], [CenaZaDobe], [Kaucja]) VALUES (1005, 4, N'Bosch', N'BS1', 15.0000, 110.0000)
INSERT [dbo].[Produkty] ([IDProduktu], [Kategoria], [Marka], [Model], [CenaZaDobe], [Kaucja]) VALUES (2003, 1, N'Bosch', N'BW3', 30.0000, 300.0000)
INSERT [dbo].[Produkty] ([IDProduktu], [Kategoria], [Marka], [Model], [CenaZaDobe], [Kaucja]) VALUES (2004, 1, N'DeWalt', N'DW1', 12.0000, 122.0000)
SET IDENTITY_INSERT [dbo].[Produkty] OFF
SET IDENTITY_INSERT [dbo].[ProduktySz] ON 

INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (4, 2, 1, 5)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (5, 2, 1, 5)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (1002, 1002, 1, 5)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (1003, 1002, 1, 4)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (1004, 1003, 1, 4)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (1005, 1004, 1, 3)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (1006, 1005, 1, 5)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (2004, 2003, 1, 5)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (2005, 2004, 1, 3)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (2006, 1003, 1, 2)
INSERT [dbo].[ProduktySz] ([IDProduktuSZ], [IDProduktu], [IDPunktuObslugi], [Stantechniczny]) VALUES (2007, 2, 1, 2)
SET IDENTITY_INSERT [dbo].[ProduktySz] OFF
SET IDENTITY_INSERT [dbo].[PunktyObslugi] ON 

INSERT [dbo].[PunktyObslugi] ([IDPunktuObslugi], [Ulica], [NrDomu], [Miasto]) VALUES (1, N'1 Maja', N'12', N'Wisla')
SET IDENTITY_INSERT [dbo].[PunktyObslugi] OFF
SET IDENTITY_INSERT [dbo].[Wypozyczenie] ON 

INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (2, CAST(N'2018-04-26T08:07:56.1300000' AS DateTime2), CAST(N'2018-04-28T08:07:51.9890000' AS DateTime2), CAST(N'2018-04-26T10:56:08.4219624' AS DateTime2), N'11111111111', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (3, CAST(N'2018-04-26T08:07:56.1300000' AS DateTime2), CAST(N'2018-04-28T08:07:51.9890000' AS DateTime2), CAST(N'2018-05-17T10:06:14.5005582' AS DateTime2), N'11111111111', N'1', N'1')
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (6, CAST(N'2018-05-10T14:17:15.3416598' AS DateTime2), CAST(N'2018-05-25T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:05:21.4557541' AS DateTime2), N'11111111111', N'0', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (7, CAST(N'2018-05-10T14:17:55.5665828' AS DateTime2), CAST(N'2018-05-23T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:05:23.9641540' AS DateTime2), N'12121212121', N'0', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (8, CAST(N'2018-05-10T14:24:54.1232946' AS DateTime2), CAST(N'2018-05-16T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:06:15.4580560' AS DateTime2), N'11111111111', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (9, CAST(N'2018-05-10T14:27:06.4784834' AS DateTime2), CAST(N'2018-05-16T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:05:25.7699449' AS DateTime2), N'11111111111', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (10, CAST(N'2018-05-10T14:27:54.9411121' AS DateTime2), CAST(N'2018-05-03T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:06:17.5140757' AS DateTime2), N'12121212121', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (11, CAST(N'2018-05-10T14:30:00.8996351' AS DateTime2), CAST(N'2018-05-18T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:07:17.4542808' AS DateTime2), N'11111111111', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (12, CAST(N'2018-05-10T14:39:09.0499815' AS DateTime2), CAST(N'2018-05-22T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:06:20.1920189' AS DateTime2), N'12121212121', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (1006, CAST(N'2018-05-11T10:55:07.3664381' AS DateTime2), CAST(N'2018-05-04T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:06:20.7763622' AS DateTime2), N'11111111111', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (2006, CAST(N'2018-05-17T10:02:33.5293269' AS DateTime2), CAST(N'2018-05-16T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:07:18.5985262' AS DateTime2), N'12121212121', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (2007, CAST(N'2018-05-17T10:09:13.1945677' AS DateTime2), CAST(N'2018-05-10T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:09:16.1176233' AS DateTime2), N'11111111111', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (2008, CAST(N'2018-05-17T10:09:44.1222086' AS DateTime2), CAST(N'2018-05-03T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:18:37.0575531' AS DateTime2), N'11111111111', N'1', N'1')
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (2009, CAST(N'2018-05-17T10:11:31.8709749' AS DateTime2), CAST(N'2018-05-04T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:17:17.8225627' AS DateTime2), N'11111111111', N'1', N'1')
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (2010, CAST(N'2018-05-17T10:17:08.6630378' AS DateTime2), CAST(N'2018-05-22T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:17:18.6789546' AS DateTime2), N'12121212121', N'1', N'1')
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (2011, CAST(N'2018-05-17T10:18:51.3287839' AS DateTime2), CAST(N'2018-05-10T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-17T10:19:18.9993239' AS DateTime2), N'11111111111', N'1', N'1')
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (3006, CAST(N'2018-05-24T10:07:30.4535192' AS DateTime2), CAST(N'2018-05-22T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-24T10:35:14.9915480' AS DateTime2), N'12121212121', N'1', N'1')
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (3007, CAST(N'2018-05-24T10:34:54.2032412' AS DateTime2), CAST(N'2018-05-26T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-24T10:35:20.2723023' AS DateTime2), N'12121212121', N'1', N'1')
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (3008, CAST(N'2018-05-24T10:36:52.4872100' AS DateTime2), CAST(N'2018-05-25T00:00:00.0000000' AS DateTime2), CAST(N'2018-05-24T10:37:07.7080480' AS DateTime2), N'11111111111', N'1', N'1')
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (3009, CAST(N'2018-05-24T10:40:16.2699902' AS DateTime2), CAST(N'2018-05-26T00:00:00.0000000' AS DateTime2), NULL, N'11111111111', N'1', NULL)
INSERT [dbo].[Wypozyczenie] ([IDWypozyczenia], [DataWypozyczenia], [DataDoZwrotu], [DataZwrotu], [IDKlienta], [IDPracWydajacego], [IDPracOdbierajacego]) VALUES (3010, CAST(N'2018-05-24T10:52:43.3692862' AS DateTime2), CAST(N'2018-05-26T00:00:00.0000000' AS DateTime2), NULL, N'123123', N'1', NULL)
SET IDENTITY_INSERT [dbo].[Wypozyczenie] OFF
SET IDENTITY_INSERT [dbo].[WypozyczenieSz] ON 

INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2, 2, 1004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3, 3, 1005)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (4, 6, 1002)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (5, 7, 1002)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (6, 7, 1003)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (7, 7, 2004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (8, 8, 1002)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (9, 9, 1002)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (10, 9, 1003)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (11, 10, 1004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (12, 11, 1003)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (13, 12, 2006)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (1004, 1006, 5)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2004, 2006, 1002)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2005, 2007, 1005)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2006, 2008, 2004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2007, 2008, 1004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2008, 2009, 1004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2009, 2010, 1004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2010, 2010, 1006)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (2011, 2011, 1003)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3004, 3006, 1002)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3005, 3007, 1004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3006, 3007, 2006)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3007, 3008, 1003)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3008, 3008, 1006)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3009, 3008, 2005)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3010, 3009, 1005)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3011, 3009, 1002)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3012, 3009, 1004)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3013, 3010, 1002)
INSERT [dbo].[WypozyczenieSz] ([IDWypozyczeniaSZ], [IDWypozyczenia], [IDProduktuSz]) VALUES (3014, 3010, 1003)
SET IDENTITY_INSERT [dbo].[WypozyczenieSz] OFF
ALTER TABLE [dbo].[Pracownicy]  WITH CHECK ADD FOREIGN KEY([IDPunktuObslugi])
REFERENCES [dbo].[PunktyObslugi] ([IDPunktuObslugi])
GO
ALTER TABLE [dbo].[Produkty]  WITH CHECK ADD FOREIGN KEY([Kategoria])
REFERENCES [dbo].[Kategorie] ([IDKategorii])
GO
ALTER TABLE [dbo].[ProduktySz]  WITH CHECK ADD FOREIGN KEY([IDProduktu])
REFERENCES [dbo].[Produkty] ([IDProduktu])
GO
ALTER TABLE [dbo].[ProduktySz]  WITH CHECK ADD FOREIGN KEY([IDPunktuObslugi])
REFERENCES [dbo].[PunktyObslugi] ([IDPunktuObslugi])
GO
ALTER TABLE [dbo].[Rezerwacje]  WITH CHECK ADD FOREIGN KEY([IDKlienta])
REFERENCES [dbo].[Klienci] ([PESEL])
GO
ALTER TABLE [dbo].[RezerwacjeSz]  WITH CHECK ADD FOREIGN KEY([IDProduktuSZ])
REFERENCES [dbo].[ProduktySz] ([IDProduktuSZ])
GO
ALTER TABLE [dbo].[RezerwacjeSz]  WITH CHECK ADD FOREIGN KEY([IDRezerwacji])
REFERENCES [dbo].[Rezerwacje] ([IDRezerwacji])
GO
ALTER TABLE [dbo].[Wypozyczenie]  WITH CHECK ADD  CONSTRAINT [Wypozyczenie_Klienci_PESEL_fk] FOREIGN KEY([IDKlienta])
REFERENCES [dbo].[Klienci] ([PESEL])
GO
ALTER TABLE [dbo].[Wypozyczenie] CHECK CONSTRAINT [Wypozyczenie_Klienci_PESEL_fk]
GO
ALTER TABLE [dbo].[Wypozyczenie]  WITH CHECK ADD  CONSTRAINT [Wypozyczenie_Pracownicy_PESEL_fk] FOREIGN KEY([IDPracOdbierajacego])
REFERENCES [dbo].[Pracownicy] ([PESEL])
GO
ALTER TABLE [dbo].[Wypozyczenie] CHECK CONSTRAINT [Wypozyczenie_Pracownicy_PESEL_fk]
GO
ALTER TABLE [dbo].[Wypozyczenie]  WITH CHECK ADD  CONSTRAINT [Wypozyczenie_Pracownicy_PESEL_fk_2] FOREIGN KEY([IDPracWydajacego])
REFERENCES [dbo].[Pracownicy] ([PESEL])
GO
ALTER TABLE [dbo].[Wypozyczenie] CHECK CONSTRAINT [Wypozyczenie_Pracownicy_PESEL_fk_2]
GO
ALTER TABLE [dbo].[WypozyczenieSz]  WITH CHECK ADD FOREIGN KEY([IDProduktuSz])
REFERENCES [dbo].[ProduktySz] ([IDProduktuSZ])
GO
ALTER TABLE [dbo].[WypozyczenieSz]  WITH CHECK ADD FOREIGN KEY([IDWypozyczenia])
REFERENCES [dbo].[Wypozyczenie] ([IDWypozyczenia])
GO
USE [master]
GO
ALTER DATABASE [Wypozyczalnia] SET  READ_WRITE 
GO
