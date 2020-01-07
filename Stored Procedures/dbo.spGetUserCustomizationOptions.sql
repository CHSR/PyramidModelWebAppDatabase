SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 10/02/2019
-- Description:	This stored procedure returns the customization
-- options for a certain user
-- =============================================
CREATE PROC [dbo].[spGetUserCustomizationOptions]
	@Username VARCHAR(256) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the options the user has selected
	DECLARE @tblSelectedOptions TABLE (
		Username VARCHAR(256) NOT NULL,
		UserCustomizationOptionPK INT NULL,
		OptionTypePK INT NOT NULL,
		OptionTypeDescription VARCHAR(250) NOT NULL,
		OptionValuePK INT NULL,
		OptionValueDescription VARCHAR(250) NULL,
		OptionValue VARCHAR(250) NULL
	)

	--To hold the unselected options for the user with the defaults for that option
	DECLARE @tblOptionDefaults TABLE (
		Username VARCHAR(256) NOT NULL,
		UserCustomizationOptionPK INT NULL,
		OptionTypePK INT NOT NULL,
		OptionTypeDescription VARCHAR(250) NOT NULL,
		OptionValuePK INT NULL,
		OptionValueDescription VARCHAR(250) NULL,
		OptionValue VARCHAR(250) NULL
	)
	
	--To hold all the options for the user with defaults if the user didn't select one
	DECLARE @tblFinalSelect TABLE (
		Username VARCHAR(256) NOT NULL,
		UserCustomizationOptionPK INT NULL,
		OptionTypePK INT NOT NULL,
		OptionTypeDescription VARCHAR(250) NOT NULL,
		OptionValuePK INT NULL,
		OptionValueDescription VARCHAR(250) NULL,
		OptionValue VARCHAR(250) NULL
	)
	
	--Get the selected customization options
	INSERT INTO @tblSelectedOptions
	(
	    Username,
		UserCustomizationOptionPK,
	    OptionTypePK,
	    OptionTypeDescription,
	    OptionValuePK,
	    OptionValueDescription,
	    OptionValue
	)
	SELECT @Username, 
		   uco.UserCustomizationOptionPK, 
		   ccot.CodeCustomizationOptionTypePK, 
		   ccot.Description, 
		   ccov.CodeCustomizationOptionValuePK, 
		   ccov.Description, 
		   ccov.Value
	FROM dbo.CodeCustomizationOptionType ccot
	LEFT JOIN dbo.UserCustomizationOption uco ON uco.CustomizationOptionTypeCodeFK = ccot.CodeCustomizationOptionTypePK AND uco.Username = @Username
	LEFT JOIN dbo.CodeCustomizationOptionValue ccov ON ccov.CodeCustomizationOptionValuePK = uco.CustomizationOptionValueCodeFK


	--Fill the table with defaults for the missing options
	INSERT INTO @tblOptionDefaults
	(
	    Username,
		UserCustomizationOptionPK,
	    OptionTypePK,
	    OptionTypeDescription,
	    OptionValuePK,
	    OptionValueDescription,
	    OptionValue
	)
	SELECT tso.Username,
		   tso.UserCustomizationOptionPK,
           tso.OptionTypePK,
           tso.OptionTypeDescription,
           ccov.CodeCustomizationOptionValuePK,
		   ccov.Description,
		   ccov.Value
	FROM @tblSelectedOptions tso
	INNER JOIN dbo.CodeCustomizationOptionValue ccov ON ccov.CustomizationOptionTypeCodeFK = tso.OptionTypePK AND ccov.IsDefault = 1
	WHERE tso.OptionValuePK IS NULL

	--Add the selected options to the final select table
	INSERT INTO @tblFinalSelect
	(
	    Username,
		UserCustomizationOptionPK,
	    OptionTypePK,
	    OptionTypeDescription,
	    OptionValuePK,
	    OptionValueDescription,
	    OptionValue
	)
	SELECT tso.Username,
		   tso.UserCustomizationOptionPK,
           tso.OptionTypePK,
           tso.OptionTypeDescription,
           tso.OptionValuePK,
           tso.OptionValueDescription,
           tso.OptionValue 
	FROM @tblSelectedOptions tso
	WHERE tso.OptionValuePK IS NOT NULL

	--Add the defaults to the final select table
	INSERT INTO @tblFinalSelect
	(
	    Username,
		UserCustomizationOptionPK,
	    OptionTypePK,
	    OptionTypeDescription,
	    OptionValuePK,
	    OptionValueDescription,
	    OptionValue
	)
	SELECT tod.Username,
		   tod.UserCustomizationOptionPK,
           tod.OptionTypePK,
           tod.OptionTypeDescription,
           tod.OptionValuePK,
           tod.OptionValueDescription,
           tod.OptionValue 
	FROM @tblOptionDefaults tod

	--Final select
	SELECT *
	FROM @tblFinalSelect tfs
END
GO
