Public with sharing class cpqApiTest {
    
    public static void cpqApiTest() {
        
        /*
        * set params for async operations
         */
        String quoteId = 'a0q1U000000AC02QAG';
        String productModels = '';
        String pricebookId = '01s1U000003sRcjQAE';
        Map<Id, Product2> allProducts = new Map<Id, Product2>([SELECT Id FROM Product2]);

        System.enqueueJob(new createQuoteAsync(quoteId, productModels, pricebookId, allProducts));
    }

    public static void asyncUpdateQuote(String quoteId, String productModels){

        // queue QuoteModel create/update
        System.enqueueJob(new updateQuote(quoteId, productModels));
    }
}
