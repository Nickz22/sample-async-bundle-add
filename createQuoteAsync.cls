public with sharing class createQuoteAsync implements Queueable {

    // parent quote
    String quoteId;
    // in-memory ProductModels JSON String
    String productModels;
    // pricebookId to use for ProductModel creation
    String pricebookId;
    // all products needing to be processed
    Map<Id, Product2> remainingProducts = new Map<Id, Product2>();
    // set batch size
    Integer batchSize = 50;

    public createQuoteAsync(String quoteId, String productModels, String pricebookId, Map<Id, Product2> remainingProducts){

        this.quoteId = quoteId;
        this.productModels = productModels;
        this.pricebookId = pricebookId;
        this.remainingProducts = remainingProducts;
    }

    public void execute(QueueableContext context) {
        
        // Products to be processed in this transaction
    	List<Product2> thisBatch = new List<Product2>();
        
        Integer i = 0;

        /* 
        * To avoid hitting SOQL limits, loop through remainingProducts to create 50 product batch ....
         * Async transactional SOQL limit is 200, aggregate query limit is 600 .... 
        * 50 Products * 8 aggregate queries ~ 400 aggregate queries per async transaction.
         */
        for(Id rP : remainingProducts.keyset()){ 

            if(i<batchSize){

                // put this product in batch list
                thisBatch.add(remainingProducts.get(rP));

                // to keep progress, remove this product from remaining map
                remainingProducts.remove(rP);

                // iterator
                i++;

            }else{

                break;
            }
        }
        
        /*
        * To populate productModels (for eventual use in Quote Model update), 
         * loop through thisBatch to create and concatenate ProductModel for each entry.
        */
        
        // init loop var
        String productId;
        // set bundle currency
        String curr = 'USD';

        for(Product2 p : thisBatch){

            // get Id for ProductModel
            productId = p.Id;

            // check if this ProductModel will be first in array
            if(productModels != ''){
                
                // comma-separate subsequent ProductModels 
                productModels += ',';
            }

            // init this ProductModel
            productModels += SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductLoader', productId, '{"pricebookId" : "' + pricebookId + '", "currencyCode" : "' + curr + '"}');
        }

        if(remainingProducts.keyset().size() > 0){
            
            // requeue until remainingProducts == 0            
            System.enqueueJob(new createQuoteAsync(quoteId, productModels, pricebookId, remainingProducts));

        }else{

            // update Quote
            cpqApiTest.asyncUpdateQuote(quoteId, productModels);

        }
    }
}
