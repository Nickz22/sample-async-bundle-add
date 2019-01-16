public with sharing class updateQuote implements Queueable{

    String quoteId;
    String productModels;
    
    public updateQuote(String quoteId, String productModels) {
        
        // create model from this Id
        this.quoteId = quoteId;
        // finished productModel from createQuoteAsync.cls
        this.productModels = productModels;
    }

    public void execute(QueueableContext context){

        // init quote model
        String quoteModel = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);

        // update quote model
        String updatedQuoteModel = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteProductAdder', null, '{"quote" : ' + quoteModel + ', "products" : [' + productModels + '], "ignoreCalculate" : true}');

         // save quote
        String savedQuoteModel = SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', updatedQuoteModel);

    }
}