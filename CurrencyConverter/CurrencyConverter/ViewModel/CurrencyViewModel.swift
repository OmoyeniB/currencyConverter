import Foundation
import RealmSwift

final class CurrencyViewModel {

    var persistedRateList: Results<Currency>?
    var persistRate: CurrencyDictionary?
    var currency = Currency()
    var currencyObject: [CurrencyDictionary]?
    var timeStamp = 0
    var date = ""
    var loadCurrencyDropDown: [String] = []
    let persistRealm = RealmPersistenceStore()
    var base: [String] = [String]()
    var urlString: String?
    var apiClass: ApiCall?
    var readDataSaved : ((Bool) -> Void)?
    var rateArray = [Double]()
    var getConversionRate: (([Double]) -> Void)?
    var getDate: ((Int) -> Void)?
    
    init(apiString: String) {
        self.urlString = apiString
        apiClass = ApiCall(urlLink: urlString ?? "")
    }
    
    func saveData(){
        apiClass?.getData(completionHandler: { [self] result in
            self.base.append(result.base)
            self.date = result.date
            self.timeStamp = result.timestamp
            getDate?(timeStamp)
            for (key, value) in result.rates{
                persistRate = CurrencyDictionary()
                persistRate?.currency = key
                persistRate?.rate = value
                currency.currency.append(persistRate!)
                rateArray.append(value)
                
                getConversionRate?(rateArray)
            }
            persistRealm.delete()
            persistRealm.saveData(of: currency)
            readDataSaved?(true)
        })
    }
    
    func passRetreivedData(completionHandler: ( @escaping (BaseCurrencyContainer) -> Void )) {
        var container : BaseCurrencyContainer?
        readDataSaved = { dataAvailable in
            if dataAvailable {
                self.fetchDataFromRealm()
                container = BaseCurrencyContainer(base: self.base, currency: self.loadCurrencyDropDown)
                completionHandler(container!)
            }
        }
    }
    
    func fetchDataFromRealm(){
        self.persistedRateList = persistRealm.readData()
        let data = persistedRateList?.first?.currency
        if let keys = data {
            for i in 0..<keys.count {
                loadCurrencyDropDown.append(keys[i].currency)
            }
        }
    }
}
