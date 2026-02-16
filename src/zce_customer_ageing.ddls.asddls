@ObjectModel: {
  query: {
    implementedBy: 'ABAP:ZCL_CUSTOMER_AGEING'
  }
}
@UI.headerInfo: { 
  typeName: 'Customer Journal Entry',
  typeNamePlural: 'Customer Journal Entries' 
}
@EndUserText.label: 'Custom entity for Customer Accounting'
define custom entity ZCE_CUSTOMER_AGEING
{
@UI.facet: [{ id : 'Customer',
  purpose: #STANDARD,
  type: #IDENTIFICATION_REFERENCE,
  label: 'Customer Ageing',
   position: 10 }]
 
  // ============================================
  // KEY FIELDS
  // ============================================
  
  @UI.selectionField: [{ position: 23 }]
  @EndUserText.label: 'Customer'
  @UI.lineItem: [{ label: 'Customer', position: 10, importance: #HIGH }]
  @UI.identification: [{ label: 'Customer', position: 10, qualifier: 'CustomerAgeing' }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer', element: 'Customer' } }]
  key customer: kunnr;
  
   @UI.selectionField: [{ position: 24 }]
   @EndUserText.label: 'Customer Name'
  @UI.lineItem: [{ label: 'Customer Name', position: 11, importance: #HIGH }]
  @UI.identification: [{ label: 'Customer Name', position: 10, qualifier: 'CustomerAgeing' }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer', element: 'Customer' } }]
  key customername: kunnr;
  
  
  //  @UI.selectionField: [{ position: 50 }]
  @EndUserText.label: 'Fiscal Year'
  @UI.lineItem: [{ label: 'Fiscal Year', position: 60, importance: #HIGH }]
  @UI.identification: [{ label: 'Fiscal Year', position: 20, qualifier: 'CustomerAgeing' }]
 key fiscalyear: gjahr;
 
  @UI.selectionField: [{ position: 21 }]
    @UI.lineItem: [{ label: 'Accounting Document', position: 70, importance: #HIGH }]
  @UI.identification: [{ label: 'Accounting Document', position: 30 }]
  @EndUserText.label: 'Accounting Document'
  key Accountingdocument: belnr_d;
//  
  
//  @UI.lineItem: [{ position: 45, importance: #HIGH }]    
//@UI.selectionField: [{ position: 25 }]
//@EndUserText.label: 'Document Type'
//@Consumption.valueHelpDefinition: [{ entity: { name: 'i_accountingdocumenttype', element: 'AccountingDocumentType' } }]
// key Accountingdocumenttype : abap.char(10);

  @UI.selectionField: [{ position: 10 }]
  @EndUserText.label: 'Key Date (Aging As Of)'
  keydate                     : datum;


  @UI.lineItem: [{ label: 'Baseline Date', position: 40, importance: #HIGH }]
  @UI.identification: [{ label: 'Baseline Date', position: 40  }]
  @EndUserText.label: 'Baseline Date'
  duecalculationbasedate : datum;

  @UI.selectionField: [{ position: 18 }]
  @UI.lineItem: [{ label: 'Company Code', position: 50, importance: #HIGH }]
  @UI.identification: [{ label: 'Company Code', position: 10  }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }]
  companycode: bukrs;




//  @UI.selectionField: [{ position: 60 }]


  @UI.lineItem: [{ label: 'Document Item', position: 80, importance: #HIGH }]
  @UI.identification: [{ label: 'Accounting Document Item', position: 40  }]
accountingdocumentItem: buzei;

  // ============================================
  // CUSTOMER INFORMATION FIELDS
  // ============================================

  @UI.lineItem: [{ label: 'Customer Account Group', position: 20, importance: #HIGH }]
  @UI.identification: [{ label: 'Customer Account Group', position: 20   }]
  customeraccountGroup: abap.char(4);

  @UI.lineItem: [{ label: 'Accounting Clerk', position: 30, importance: #MEDIUM}]
  @UI.identification: [{ label: 'Accounting Clerk', position: 30   }]
  accountingclerk: abap.char(2);
  
@UI.selectionField: [{ position: 26 }]
  @UI.lineItem: [{ label: 'Reconciliation Account', position: 40, importance: #HIGH }]
  @UI.identification: [{ label: 'Reconciliation Account', position: 40   }]
  @EndUserText.label: 'RC Account'
  reconciliationaccount: saknr;

  @UI.lineItem: [{ label: 'Credit Limit', position: 45, importance: #HIGH }]
  @UI.identification: [{ label: 'Credit Limit', position: 45   }]
  @EndUserText.label: 'Credit Limit'
  @Semantics.amount.currencyCode: 'companycodecurrency'
  creditlimit: wrbtr;

  // ============================================
  // GEOGRAPHIC FIELDS
  // ============================================

//  @UI.selectionField: [{ position: 111 }]
 @EndUserText.label: 'Customer Region'
  @UI.lineItem: [{ label: 'Region', position: 171, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Region', position: 51   }]
  customerregion: abap.char(10);

////  @UI.selectionField: [{ position: 112 }]
//  @UI.lineItem: [{ label: 'Region', position: 172, importance: #MEDIUM }]
//  @UI.identification: [{ label: 'Region', position: 52   }]
//  customerregion: abap.char(3);

//  @UI.selectionField: [{ position: 113 }]
 @EndUserText.label: 'Customer Area'
  @UI.lineItem: [{ label: 'Area', position: 173, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Area', position: 53   }]
  customerarea: abap.char(10);

//  @UI.selectionField: [{ position: 114 }]
 @EndUserText.label: 'Customer Cluster'
  @UI.lineItem: [{ label: 'Cluster', position: 174, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Cluster', position: 54   }]
  customercluster: abap.char(10);


 @UI.lineItem: [{ label: 'District', position: 175, importance: #MEDIUM }]
  @EndUserText.label: 'District'
  @UI.identification: [{ label: 'Customer Group 4', position: 55   }]
 District : abap.char(10);


//  @UI.selectionField: [{ position: 115 }]
 @EndUserText.label: 'Customer Group'
  @UI.lineItem: [{ label: 'Customer Group 4', position: 176, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Customer Group 4', position: 55   }]
  customergroup4: abap.char(10);

  // ============================================
  // DOCUMENT FIELDS
  // ============================================

  @UI.lineItem: [{ label: 'Ledger GL Line Item', position: 90, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Ledger GL Line Item', position: 50  }]
  ledgergllineItem: abap.char(6);

  @UI.lineItem: [{ label: 'G/L Account', position: 100, importance: #HIGH }]
  @UI.identification: [{ label: 'G/L Account', position: 60  }]
  glaccount: saknr;


//  @UI.lineItem: [{ label: 'Transaction Currency', position: 110, importance: #HIGH }]
  @UI.identification: [{ label: 'Transaction Currency', position: 70  }]
    @Consumption.filter.hidden: true
  transactioncurrency: waers;

 @UI.lineItem: [{ label: 'Company Code Currency', position: 110, importance: #MEDIUM }]
@UI.selectionField: [{ position: 29 }]
  @UI.identification: [{ label: 'Company Code Currency', position: 80  }]
    @EndUserText.label: 'Display Currency'
     @Consumption.filter.defaultValue: 'INR'
  companycodecurrency: waers;

  @UI.selectionField: [{ position: 22 }]
  @EndUserText.label: 'Document Type'
  @UI.lineItem: [{ label: 'Document Type', position: 115, importance: #HIGH }]
  @UI.identification: [{ label: 'Document Type', position: 75  }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_AccountingDocumentType', element: 'AccountingDocumentType' } }]
  documenttype: abap.char(2);

//  @UI.selectionField: [{ position: 86 }]
@EndUserText.label: 'Document Date'
  @UI.lineItem: [{ label: 'Document Date', position: 116, importance: #HIGH }]
  @UI.identification: [{ label: 'Document Date', position: 76  }]
  documentdate: datum;

@EndUserText.label: 'Posting Date'
  @UI.lineItem: [{ label: 'Posting Date', position: 117, importance: #HIGH }]
  @UI.identification: [{ label: 'Posting Date', position: 77  }]
  postingdate: datum;

//  @UI.selectionField: [{ position: 90 }]
@EndUserText.label: 'Net Due Date'
  @UI.lineItem: [{ label: 'Net Due Date', position: 130, importance: #HIGH }]
  @UI.identification: [{ label: 'Net Due Date', position: 90  }]
  netduedate: datum;

@EndUserText.label: 'Payment Terms'
  @UI.lineItem: [{ label: 'Payterms', position: 131,importance:  #HIGH}]
  @UI.identification: [{ label: 'Payterms', position: 91  }]
  paymentterms : abap.char(4);

  @UI.lineItem: [{ label: 'Profit Center', position: 140, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Profit Center', position: 100  }]
  profitcenter: prctr;

  @UI.lineItem: [{ label: 'Segment', position: 150, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Segment', position: 110  }]
  segment: fb_segment;

//  @UI.selectionField: [{ position: 100 }]
  @EndUserText.label: 'Special G/L Code'
  @UI.lineItem: [{ label: 'Special G/L Code', position: 160, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Special G/L Code', position: 120  }]
  specialglcode: abap.char(1);

  @UI.lineItem: [{ label: 'Billing Document', position: 170, importance: #HIGH }]
  @UI.identification: [{ label: 'Billing Document', position: 130  }]
  billingdocument: abap.char(10);

  // ============================================
  // AMOUNT FIELDS
  // ============================================
//
//  @UI.lineItem: [{ label: 'Amount in CC Currency', position: 180}]
 @UI.selectionField: [{ position: 27 }]
  @UI.identification: [{ label: 'Amount in Company Code Currency', position: 140  }]
  @EndUserText.label: 'Amount'
  @Semantics.amount.currencyCode: 'companycodecurrency'
  amountincompanycodecurrency: wrbtr;

  @UI.lineItem: [{ label: 'Transaction Amount', position: 181, importance: #MEDIUM }]
  @UI.identification: [{ label: 'Amount in Transaction Currency', position: 141  }]
  @Semantics.amount.currencyCode: 'transactioncurrency'
  @EndUserText.label: 'Transaction Amount'
  @Consumption.filter.hidden: true
  amountintransactioncurrency: wrbtr;
  
   @UI.selectionField          : [{ position: 100 }]
      @EndUserText.label          : 'Exchange Rate Type'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EXCHANGERATETYPE', element: 'ExchangeRateType' } }]
      exchangeratetype            : abap.char( 10 );
  // ============================================
  // AGING CALCULATION FIELDS
  // ============================================

  @UI.lineItem: [{ label: 'Days Outstanding', position: 185, importance: #HIGH }]
  @UI.identification: [{ label: 'Days Outstanding', position: 145  }]
  daysoutstanding: abap.int4;

  @UI.lineItem: [{ label: 'Days Overdue', position: 186, importance: #HIGH }]
  @UI.identification: [{ label: 'Days Overdue', position: 146  }]
  daysoverdue: abap.int4;

  // ============================================
  // 7 AGING INTERVALS - AS FILTERS & OUTPUT
  // ============================================

  // These act as INPUT FILTERS (selection fields)
//  @UI.selectionField: [{ position: 11 }]
//  @EndUserText.label: 'Net Due Interval 1'
//  @Consumption.filter.defaultValue: '0'
//  netdueinterval1: abap.int4;

  @UI.selectionField: [{ position: 11 }]
  @EndUserText.label: 'Net Due Interval 1'
  @Consumption.filter.defaultValue: '30'
  netdueinterval2: abap.int4;

  @UI.selectionField: [{ position: 12 }]
  @EndUserText.label: 'Net Due Interval 2'
  @Consumption.filter.defaultValue: '60'
  netdueinterval3: abap.int4;

  @UI.selectionField: [{ position: 13 }]
  @EndUserText.label: 'Net Due Interval 3'
  @Consumption.filter.defaultValue: '90'
  netdueinterval4: abap.int4;

  @UI.selectionField: [{ position: 14 }]
  @EndUserText.label: 'Net Due Interval 4'
  @Consumption.filter.defaultValue: '120'
  netdueinterval5: abap.int4;

  @UI.selectionField: [{ position: 15 }]
  @EndUserText.label: 'Net Due Interval 5'
  @Consumption.filter.defaultValue: '150'
  netdueinterval6: abap.int4;

  @UI.selectionField: [{ position: 16 }]
  @EndUserText.label: 'Net Due Interval 6'
  @Consumption.filter.defaultValue: '180'
  netdueinterval7: abap.int4;
  
  @UI.selectionField: [{ position: 17 }]
  @EndUserText.label: 'Net Due Interval 7'
  @Consumption.filter.defaultValue: '210'
  netdueinterval8: abap.int4;

  // These are OUTPUT AMOUNTS (displayed in table)
  @UI.lineItem: [{ label: 'Interval 1', position: 190, importance: #HIGH }]
  @UI.fieldGroup: [{ qualifier: 'AgingIntervals', position: 10, label: 'Interval 1 Amount' }]
   @Semantics.amount.currencyCode: 'companycodecurrency'
  interval1_amount: wrbtr;

  @UI.lineItem: [{ label: 'Interval 2', position: 200, importance: #HIGH }]
  @UI.fieldGroup: [{ qualifier: 'AgingIntervals', position: 20, label: 'Interval 2 Amount' }]
  @Semantics.amount.currencyCode: 'companycodecurrency'
  interval2_amount: wrbtr;

  @UI.lineItem: [{ label: 'Interval 3', position: 210, importance: #HIGH }]
  @UI.fieldGroup: [{ qualifier: 'AgingIntervals', position: 30, label: 'Interval 3 Amount' }]
   @Semantics.amount.currencyCode: 'companycodecurrency'
  interval3_amount: wrbtr;

  @UI.lineItem: [{ label: 'Interval 4', position: 220, importance: #HIGH }]
  @UI.fieldGroup: [{ qualifier: 'AgingIntervals', position: 40, label: 'Interval 4 Amount' }]
  @Semantics.amount.currencyCode: 'companycodecurrency'
  interval4_amount: wrbtr;

  @UI.lineItem: [{ label: 'Interval 5', position: 230, importance: #HIGH }]
  @UI.fieldGroup: [{ qualifier: 'AgingIntervals', position: 50, label: 'Interval 5 Amount' }]
  @Semantics.amount.currencyCode: 'companycodecurrency'
  interval5_amount: wrbtr;

  @UI.lineItem: [{ label: 'Interval 6', position: 240, importance: #HIGH }]
  @UI.fieldGroup: [{ qualifier: 'AgingIntervals', position: 60, label: 'Interval 6 Amount' }]
  @Semantics.amount.currencyCode: 'companycodecurrency'
  interval6_amount: wrbtr;

  @UI.lineItem: [{ label: 'Interval 7', position: 250, importance: #HIGH }]
  @UI.fieldGroup: [{ qualifier: 'AgingIntervals', position: 70, label: 'Interval 7 Amount' }]
  @Semantics.amount.currencyCode: 'companycodecurrency'
  interval7_amount: wrbtr;

  // Interval Category (for grouping)
  @UI.lineItem: [{ label: 'Interval Category', position: 270, importance: #MEDIUM }]
  intervalcategory: abap.char(1);
  
//  @UI.identification          : [{ position: 280, importance: #MEDIUM }]
//      @EndUserText.label          : 'baseline date'
//      baselinedate                : datum;

  // NEW: Number of Intervals Parameter
//  @UI.selectionField: [{ position: 6 }]
   @EndUserText.label: 'Number of Intervals (1-7)'
   intervalcount: abap.int1;

//  // Total Outstanding (optional - sum of all intervals)
//  @UI.lineItem: [{ label: 'Total Outstanding', position: 280, importance: #HIGH }]
//  @Semantics.amount.currencyCode: 'companycodecurrency'
//  totaloutstanding: wrbtr;
}
