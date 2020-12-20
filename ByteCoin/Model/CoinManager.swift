
import Foundation

protocol CoinManagerDelegate {
    func updateExchangeRate(currency: String, exchangeRate: String )
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "CF11CD53-5D1E-4ACA-983C-CF769DE85782"
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String)  {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
   
        //1.Create a URL
        if let url = URL(string: urlString){
            
            //2.Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3.Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                }
                
                if let safeData = data{
                    if let price = parseJSON(safeData){
                        let bitcoinPrice = String(format: "%.2f", price)
                        delegate?.updateExchangeRate(currency: currency, exchangeRate: bitcoinPrice)
                        
                    }
                }
                
            }
            //4.Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastRate = decodedData.rate
      
            return lastRate
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}
