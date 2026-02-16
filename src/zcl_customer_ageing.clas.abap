*
CLASS zcl_customer_ageing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      calculate_aging_intervals
        IMPORTING
          iv_amount            TYPE wrbtr
          iv_days_overdue      TYPE i
          iv_interval_count    TYPE int1
        EXPORTING
          ev_interval1_amount  TYPE wrbtr
          ev_interval2_amount  TYPE wrbtr
          ev_interval3_amount  TYPE wrbtr
          ev_interval4_amount  TYPE wrbtr
          ev_interval5_amount  TYPE wrbtr
          ev_interval6_amount  TYPE wrbtr
          ev_interval7_amount  TYPE wrbtr
          ev_interval_category TYPE char1.
ENDCLASS.



CLASS ZCL_CUSTOMER_AGEING IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA: lt_response TYPE TABLE OF zce_customer_ageing,
          ls_response TYPE zce_customer_ageing.
     data: lv_Baseline_Date  tyPE datum.

    " Filter and sort details
    DATA(lt_clause) = io_request->get_filter( )->get_as_sql_string( ).
    DATA(lt_field) = io_request->get_requested_elements( ).
    DATA(lt_sort)   = io_request->get_sort_elements( ).

    " Pagination parameters from request
    DATA(lv_top)    = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)   = io_request->get_paging( )->get_offset( ).

    " Handle invalid pagination inputs
    IF lv_top < 0.
      lv_top = 50.
    ENDIF.

    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
    ENDTRY.

    " ===============================================
    " Extract filter ranges for all parameters
    " ===============================================
    DATA(lr_customer)          = VALUE #( lt_filter_cond[ name = 'CUSTOMER' ]-range OPTIONAL ).
    DATA(lr_fiscalyear)        = VALUE #( lt_filter_cond[ name = 'FISCALYEAR' ]-range OPTIONAL ).
    DATA(lr_companycode)       = VALUE #( lt_filter_cond[ name = 'COMPANYCODE' ]-range OPTIONAL ).
    DATA(lr_accountingdoc)     = VALUE #( lt_filter_cond[ name = 'ACCOUNTINGDOCUMENT' ]-range OPTIONAL ).
    DATA(lr_accountingdocumenttype) = VALUE #( lt_filter_cond[ name = 'ACCOUNTINGDOCUMENTTYPE' ]-range OPTIONAL ).
    DATA(lr_documenttype) = VALUE #( lt_filter_cond[ name = 'ACCOUNTINGDOCUMENTTYPE' ]-range OPTIONAL ).
    DATA(lr_duecalculationbasedate)      = VALUE #( lt_filter_cond[ name = 'BLINEDATA' ]-range OPTIONAL ).
    DATA(lr_accountingclerk)   = VALUE #( lt_filter_cond[ name = 'ACCOUNTINGCLERK' ]-range OPTIONAL ).
    DATA(lr_custaccgrp)        = VALUE #( lt_filter_cond[ name = 'CUSTOMERACCOUNTGROUP' ]-range OPTIONAL ).

    " Geographic filters - using correct field names from custom entity
    DATA(lr_customerzone)      = VALUE #( lt_filter_cond[ name = 'CUSTOMERZONE' ]-range OPTIONAL ).
    DATA(lr_customerregion)    = VALUE #( lt_filter_cond[ name = 'CUSTOMERREGION' ]-range OPTIONAL ).
    DATA(lr_customerarea)      = VALUE #( lt_filter_cond[ name = 'CUSTOMERAREA' ]-range OPTIONAL ).
    DATA(lr_customercluster)   = VALUE #( lt_filter_cond[ name = 'CUSTOMERCLUSTER' ]-range OPTIONAL ).
    DATA(lr_customerdistrict)  = VALUE #( lt_filter_cond[ name = 'CUSTOMERDISTRICT' ]-range OPTIONAL ).

    " Document Type filter
*    DATA(lr_doctype)           = VALUE #( lt_filter_cond[ name = 'DOCUMENTTYPE' ]-range OPTIONAL ).

    " Date filters
    DATA(lr_documentdate)      = VALUE #( lt_filter_cond[ name = 'DOCUMENTDATE' ]-range OPTIONAL ).
    DATA(lr_postingdate)       = VALUE #( lt_filter_cond[ name = 'POSTINGDATE' ]-range OPTIONAL ).
    DATA(lr_netduedate)        = VALUE #( lt_filter_cond[ name = 'NETDUEDATE' ]-range OPTIONAL ).
 DATA(lr_billingdoc)        = VALUE #( lt_filter_cond[ name = 'BILLINGDOCUMENT' ]-range OPTIONAL ).


IF lr_customer IS INITIAL.
  lr_customer = VALUE #( ( sign = 'I' option = 'CP' low = '*' ) ).
ENDIF.

*
*  IF lr_customer IS INITIAL.
*    " Return empty result with message
*    io_response->set_total_number_of_records( 0 ).
*    io_response->set_data( lt_response ).
*    RETURN.
*  ENDIF.
    " Key Date and Interval Count parameters
    DATA: lv_key_date       TYPE datum,
          lv_interval_count TYPE int1 VALUE 7.

    " Get Key Date from filter (default to system date)
*    TRY.
*        lv_key_date = VALUE #( lt_filter_cond[ name = 'KEYDATE' ]-range[ 1 ]-low OPTIONAL ).
*        IF lv_key_date IS INITIAL.
*          lv_key_date = sy-datum.
*        ENDIF.
*      CATCH cx_root.
*        lv_key_date = sy-datum.
*    ENDTRY.


    TRY.
        lv_key_date = VALUE #( lt_filter_cond[ name = 'KEYDATE' ]-range[ 1 ]-low OPTIONAL ).
        IF lv_key_date IS INITIAL.
          lv_key_date = sy-datum.
        ENDIF.
      CATCH cx_root.
        lv_key_date = sy-datum.
    ENDTRY.

    " Get Interval Count from filter (default to 7)
    TRY.
        lv_interval_count = VALUE #( lt_filter_cond[ name = 'INTERVALCOUNT' ]-range[ 1 ]-low OPTIONAL ).
        IF lv_interval_count IS INITIAL OR lv_interval_count < 1 OR lv_interval_count > 7.
          lv_interval_count = 7.
        ENDIF.
      CATCH cx_root.
        lv_interval_count = 7.
    ENDTRY.

    " ===============================
    "   MAIN DATA SELECTION SECTION
    " ===============================

    " Step 1: Get Customer Master Data
    SELECT
      customer,
      customeraccountgroup,
      country,
      customerclassification,
      region,
      addressid,
      districtname,
      CustomerName
    FROM i_customer
    WHERE customer IN @lr_customer
      AND customeraccountgroup IN @lr_custaccgrp
      AND region IN @lr_customerregion
    INTO TABLE @DATA(it_customer).

    if it_customer IS NOT INITIAL.

    " Step 2: Get Customer Company Data (without credit limit)
    SELECT
      customer,
      companycode,
      accountingclerk,
      reconciliationaccount,
      paymentterms
    FROM i_customercompany
    FOR ALL ENTRIES IN @it_customer
    WHERE customer = @it_customer-customer
      AND companycode IN @lr_companycode
      AND accountingclerk IN @lr_accountingclerk
    INTO TABLE @DATA(it_custcompany).


   sELECT *
    FROM I_address_2
    with PRIVILEGED ACCESS
    FOR ALL ENTRIES IN @it_customer
    WHERE addressid = @it_customer-addressid
    INTO TABLE @DATA(it_district).
endif.
    if it_custcompany IS NOT INITIAL.



select from I_CustomerSalesArea
fields AdditionalCustomerGroup1,
AdditionalCustomerGroup2,
AdditionalCustomerGroup3,
AdditionalCustomerGroup4,
customer
foR ALL ENTRIES IN @it_custcompany
where customer = @it_custcompany-customer
into table @data(it_cust_group).

    " Step 2b: Get Credit Limit from I_CreditManagementAccount
    SELECT
      businesspartner,
      creditsegment,
      customercreditlimitamount
    FROM i_creditmanagementaccount
    FOR ALL ENTRIES IN @it_custcompany
    WHERE businesspartner = @it_custcompany-customer
    INTO TABLE @DATA(it_creditlimit).

    SORT it_creditlimit BY businesspartner DESCENDING customercreditlimitamount.
    DELETE ADJACENT DUPLICATES FROM it_creditlimit COMPARING businesspartner.

    " Step 3: Get Journal Entry Items (Open Items Only)
    SELECT
      companycode,
      accountingdocument,
      fiscalyear,
      accountingdocumentitem,
      customer,
      transactioncurrency,
      companycodecurrency,
      glaccount,
      ledgergllineitem,
      segment,
      netduedate,
      profitcenter,
      specialglcode,
      amountincompanycodecurrency,
      amountintransactioncurrency,
      clearingaccountingdocument
    FROM i_journalentryitem
    FOR ALL ENTRIES IN @it_custcompany
    WHERE customer = @it_custcompany-customer
      AND companycode = @it_custcompany-companycode
      AND companycode IN @lr_companycode
      AND accountingdocument IN @lr_accountingdoc
      AND AccountingDocumentType in @lr_accountingdocumenttype
      AND netduedate IN @lr_netduedate
*      AND clearingaccountingdocument = ''
*      AND specialglcode = ''
      AND Ledger = '0L'
*      AND GLAccount = @it_custcompany-ReconciliationAccount
    INTO TABLE @DATA(it_journalitem).
    endif.

    if it_journalitem IS NOT INITIAL.

    " Step 4: Get Journal Entry Header (for Document Type and Dates)
    SELECT
      companycode,
      accountingdocument,
      fiscalyear,
      accountingdocumenttype,
      documentdate,
      postingdate,
      isreversal,
      isreversed,
      exchangeratetype,
      exchangerate
    FROM i_journalentry
    FOR ALL ENTRIES IN @it_journalitem
    WHERE companycode = @it_journalitem-companycode
      AND accountingdocument = @it_journalitem-accountingdocument
      AND fiscalyear IN @lr_fiscalyear
      AND accountingdocumenttype IN @lr_accountingdocumenttype
      AND documentdate IN @lr_documentdate
      AND postingdate IN @lr_postingdate
      AND isreversal = ''
      AND isreversed = ''
    INTO TABLE @DATA(it_journalentry).


   SELECT customer, duecalculationbasedate , accountingdocument
    FROM i_operationalacctgdocitem
    FOR ALL ENTRIES IN @it_journalitem
 WHERE companycode = @it_journalitem-companycode
 AND accountingdocument = @it_journalitem-accountingdocument
  AND fiscalyear = @it_journalitem-fiscalyear
  AND accountingdocumentitem = @it_journalitem-accountingdocumentitem
  INTO TABLE @DATA(it_basedate).
endif.
    if it_journalentry IS NOT INITIAL.

    " Step 5: Get Billing Documents
    SELECT
      billingdocument,
      soldtoparty
    FROM i_billingdocument
    FOR ALL ENTRIES IN @it_journalitem
    WHERE soldtoparty = @it_journalitem-customer
    AND AccountingDocument = @it_journalitem-AccountingDocument
    INTO TABLE @DATA(it_billing).

    select exchangerate,
    exchangeratetype
from i_exchangeraterawdata
for all entries in @it_journalentry
where exchangeratetype = @it_journalentry-ExchangeRateType
into table @data(it_exg_rate).

endif.
*    SORT it_billing BY soldtoparty DESCENDING billingdocument.
*    DELETE ADJACENT DUPLICATES FROM it_billing COMPARING soldtoparty.

    " ===============================
    "   BUILD RESPONSE DATA
    " ===============================

    LOOP AT it_journalitem ASSIGNING FIELD-SYMBOL(<item>).

      CLEAR ls_response.

      " ===== CUSTOMER MASTER DATA =====
      READ TABLE it_customer ASSIGNING FIELD-SYMBOL(<cust>)
        WITH KEY customer = <item>-customer.
      IF sy-subrc = 0.
        ls_response-customer = <cust>-customer.
        ls_response-customername = <cust>-CustomerName.
        ls_response-customeraccountgroup = <cust>-customeraccountgroup.
        ls_response-customerregion = <cust>-region.
        ls_response-District = <cust>-DistrictName.
      ENDIF.
      " ===== CUSTOMER COMPANY DATA =====
      READ TABLE it_custcompany ASSIGNING FIELD-SYMBOL(<custcomp>)
        WITH KEY customer = <item>-customer
                 companycode = <item>-companycode.
*                 AccountingClerk = .
      IF sy-subrc = 0.
        ls_response-accountingclerk = <custcomp>-accountingclerk.
        ls_response-reconciliationaccount = <custcomp>-reconciliationaccount.
        ls_response-paymentterms = <custcomp>-paymentterms.
      ENDIF.

      " ===== CREDIT LIMIT DATA =====
      READ TABLE it_creditlimit ASSIGNING FIELD-SYMBOL(<credit>)
        WITH KEY businesspartner = <item>-customer.
      IF sy-subrc = 0.
        ls_response-creditlimit = <credit>-customercreditlimitamount.
      ENDIF.

      " ===== JOURNAL ENTRY HEADER DATA =====
      READ TABLE it_journalentry ASSIGNING FIELD-SYMBOL(<je>)
        WITH KEY companycode = <item>-companycode
                 accountingdocument = <item>-accountingdocument.
      IF sy-subrc = 0.
        ls_response-fiscalyear = <je>-fiscalyear.
        ls_response-documenttype = <je>-accountingdocumenttype.
        ls_response-documentdate = <je>-documentdate.
        ls_response-postingdate = <je>-postingdate.
        ls_response-exchangeratetype = <je>-exchangeratetype.
      ENDIF.
      READ TABLE it_basedate ASSIGNING FIELD-SYMBOL(<bas>)
        WITH KEY accountingdocument = <je>-AccountingDocument.

      IF sy-subrc = 0.
        ls_response-duecalculationbasedate = <bas>-duecalculationbasedate.
      ENDIF.
      " ===== JOURNAL ENTRY ITEM DATA =====
      ls_response-companycode = <item>-companycode.
      ls_response-accountingdocument = <item>-accountingdocument.
      ls_response-accountingdocumentitem = <item>-accountingdocumentitem.
      ls_response-transactioncurrency = <item>-transactioncurrency.
      ls_response-companycodecurrency = <item>-companycodecurrency.
      ls_response-glaccount = <item>-glaccount.
      ls_response-ledgergllineitem = <item>-ledgergllineitem.
      ls_response-segment = <item>-segment.
      ls_response-netduedate = <item>-netduedate.
      ls_response-profitcenter = <item>-profitcenter.
      ls_response-specialglcode = <item>-specialglcode.
      ls_response-amountincompanycodecurrency = <item>-amountincompanycodecurrency.
      ls_response-amountintransactioncurrency = <item>-amountintransactioncurrency.


      " ===== BILLING DOCUMENT DATA =====
      READ TABLE it_billing ASSIGNING FIELD-SYMBOL(<bill>)
        WITH KEY soldtoparty = <item>-customer.
      IF sy-subrc = 0.
        ls_response-billingdocument = <bill>-billingdocument.
      ELSE.
        ls_response-billingdocument = ''.
      ENDIF.

*        READ TABLE it_exg_rate ASSIGNING FIELD-SYMBOL(<fs_exg_rate>)
*        WITH KEY exchangeratetype = <je>-ExchangeRateType.
*        if sy-subrc = 0.
*        ls_response-exchangerate = <fs_exg_rate>-ExchangeRate.
*        endif.

        READ TABLE it_district asSIGNING fieLD-SYMBOL(<fs_district>)
        with key addressid = <cust>-addressid.
        if sy-subrc = 0.
        endif.
      " ===============================================
      " CALCULATE AGING
      " ===============================================

      " Calculate Days Outstanding (from Document Date)
      IF ls_response-documentdate IS NOT INITIAL.
        ls_response-daysoutstanding = lv_key_date - ls_response-documentdate.
      ENDIF.

      " Calculate Days Overdue (from Net Due Date)
      IF ls_response-netduedate IS NOT INITIAL.
        ls_response-daysoverdue = lv_key_date - ls_response-netduedate.
      ELSE.
        " If no due date, use document date
        ls_response-daysoverdue = ls_response-daysoutstanding.
      ENDIF.

      " Calculate Aging Intervals
      calculate_aging_intervals(
        EXPORTING
          iv_amount            = ls_response-amountincompanycodecurrency
          iv_days_overdue      = ls_response-daysoverdue
          iv_interval_count    = lv_interval_count
        IMPORTING
          ev_interval1_amount  = ls_response-interval1_amount
          ev_interval2_amount  = ls_response-interval2_amount
          ev_interval3_amount  = ls_response-interval3_amount
          ev_interval4_amount  = ls_response-interval4_amount
          ev_interval5_amount  = ls_response-interval5_amount
          ev_interval6_amount  = ls_response-interval6_amount
          ev_interval7_amount  = ls_response-interval7_amount
          ev_interval_category = ls_response-intervalcategory
      ).


      " For now, using placeholder values (empty strings)
        READ TABLE it_cust_group ASSIGNING FIELD-SYMBOL(<cust_group>)
        with key customer = <custcomp>-Customer.
        if sy-subrc = 0.
      ls_response-customerregion = <cust_group>-AdditionalCustomerGroup1.
      ls_response-customerarea = <cust_group>-AdditionalCustomerGroup2.
      ls_response-customercluster = <cust_group>-AdditionalCustomerGroup3.
      ls_response-customergroup4 = <cust_group>-AdditionalCustomerGroup4.

     endif.
      " Store Key Date and Interval Count in response
      ls_response-keydate = lv_key_date.
      ls_response-intervalcount = lv_interval_count.
*      ls_response-DueCalculationBaseDate = ls_response-netduedate - ls_response-documentdate.

      APPEND ls_response TO lt_response.

    ENDLOOP.




    " ===============================
    "   PAGINATION LOGIC
    " ===============================
    DATA lv_total_count TYPE int8.
    lv_total_count = lines( lt_response ).

    DATA lt_paged TYPE TABLE OF zce_customer_ageing.
    DATA lv_index TYPE i VALUE 0.

    LOOP AT lt_response INTO DATA(ls_row).
      lv_index = lv_index + 1.
      IF lv_index > lv_skip AND lv_index <= lv_skip + lv_top.
        APPEND ls_row TO lt_paged.
      ENDIF.
    ENDLOOP.

    " Send data to UI
    io_response->set_total_number_of_records( lv_total_count ).
    io_response->set_data( lt_paged ).

  ENDMETHOD.


  METHOD calculate_aging_intervals.
    " ===============================================
    " Calculate aging intervals based on days overdue
    " ===============================================

    CLEAR: ev_interval1_amount,
           ev_interval2_amount,
           ev_interval3_amount,
           ev_interval4_amount,
           ev_interval5_amount,
           ev_interval6_amount,
           ev_interval7_amount,
           ev_interval_category.

    " Interval 1: 0-30 days
    IF iv_days_overdue <= 30.
      ev_interval1_amount = iv_amount.
      ev_interval_category = '1'.

      " Interval 2: 31-60 days
    ELSEIF iv_days_overdue > 30 AND iv_days_overdue <= 60.
      IF iv_interval_count >= 2.
        ev_interval2_amount = iv_amount.
        ev_interval_category = '2'.
      ELSE.
        ev_interval1_amount = iv_amount.
        ev_interval_category = '1'.
      ENDIF.

      " Interval 3: 61-90 days
    ELSEIF iv_days_overdue > 60 AND iv_days_overdue <= 90.
      IF iv_interval_count >= 3.
        ev_interval3_amount = iv_amount.
        ev_interval_category = '3'.
      ELSE.
        ev_interval2_amount = iv_amount.
        ev_interval_category = '2'.
      ENDIF.

      " Interval 4: 91-120 days
    ELSEIF iv_days_overdue > 90 AND iv_days_overdue <= 120.
      IF iv_interval_count >= 4.
        ev_interval4_amount = iv_amount.
        ev_interval_category = '4'.
      ELSE.
        ev_interval3_amount = iv_amount.
        ev_interval_category = '3'.
      ENDIF.

      " Interval 5: 121-150 days
    ELSEIF iv_days_overdue > 120 AND iv_days_overdue <= 150.
      IF iv_interval_count >= 5.
        ev_interval5_amount = iv_amount.
        ev_interval_category = '5'.
      ELSE.
        ev_interval4_amount = iv_amount.
        ev_interval_category = '4'.
      ENDIF.

      " Interval 6: 151-180 days
    ELSEIF iv_days_overdue > 150 AND iv_days_overdue <= 180.
      IF iv_interval_count >= 6.
        ev_interval6_amount = iv_amount.
        ev_interval_category = '6'.
      ELSE.
        ev_interval5_amount = iv_amount.
        ev_interval_category = '5'.
      ENDIF.

      " Interval 7: Over 180 days
    ELSEIF iv_days_overdue > 180.
      IF iv_interval_count >= 7.
        ev_interval7_amount = iv_amount.
        ev_interval_category = '7'.
      ELSE.
        ev_interval6_amount = iv_amount.
        ev_interval_category = '6'.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
