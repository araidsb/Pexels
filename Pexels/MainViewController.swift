//
//  MainViewController.swift
//  Pexels
//
//  Created by Арай Дуйсебекова on 29.05.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchHistoryCollectionView: UICollectionView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var searchPhotosResponse: SearchPhotos? {
        didSet {
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()
            }
        }
    }
    var photos: [Photo] {
        return searchPhotosResponse?.photos ?? []
    }
    
    let savedSearchTextArrayKey: String = "saveSearchTextArrayKey"
    var searchTextArray: [String] = [] {
        
        didSet {
            searchHistoryCollectionView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Pexels"
        
        // MARK: значение свойтсва delegate у экземпляра класса searchBar(UISerachBar)для MainViewController
        
        searchBar.delegate = self
        
        //MARK: Image UICollectionView SETUP
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        imageCollectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.refreshControl = UIRefreshControl()
        imageCollectionView.refreshControl?.addTarget(self, action: #selector(search), for: .valueChanged)
        
        // search history SETUP
        let flowLayout = searchHistoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        searchHistoryCollectionView.register(UINib(nibName: SearchTextCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SearchTextCollectionViewCell.identifier)
        searchHistoryCollectionView.dataSource = self
        
        searchTextArray = getSaveSearchTextArray()
    }
    @objc
    func search() {
        self.searchPhotosResponse = nil
        
        guard let searchText = searchBar.text else {
            print("Search bar text is nil")
            return
        }
        guard !searchText.isEmpty else {
            print("Search bar text is empty")
            return
        }
        // save searching text
        save(searchText: searchText)
        
        let endpoint: String = "https://api.pexels.com/v1/search"
        
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("Couldn't create URL Components instance from endpoint \(endpoint)")
            return
        }
        
        let parameters = [
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "per_page", value: "20")
        ]
        
        urlComponents.queryItems = parameters
        
        guard let url: URL = urlComponents.url else {
            print("URL is nil")
            return
        }
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let APIKey: String = "sVZaidEGy10bfgRSYvzjzAk1GL9nYswx8DNOIcQ55ssGipnTkPN3WDzM"
        
        urlRequest.addValue(APIKey, forHTTPHeaderField: "Authorization")
        
        if imageCollectionView.refreshControl?.isRefreshing == false {
            imageCollectionView.refreshControl?.beginRefreshing()
        }
        
        let urlSession: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = urlSession.dataTask(with: urlRequest, completionHandler: searchPhotosHandler(data:urlResponse:error:))
        
        dataTask.resume()
        
    }
    
    func searchPhotosHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        print("Method search photos handler was called")
        DispatchQueue.main.async {
            if self.imageCollectionView.refreshControl?.isRefreshing == true {
                self.imageCollectionView.refreshControl?.endRefreshing()
            }
        }

        if let error = error {
            print("Search endpoint error \(error.localizedDescription)")
            
        } else if let data = data {
            
            do {
                //                let jsonObject = try JSONSerialization.jsonObject(with: data)
                //                print("Search photos endpoint jsonobject \(jsonObject)")
                let searchPhotosResponse = try JSONDecoder().decode(SearchPhotos.self, from: data)
                print("Search photos endpoint searchPhotos response   - \(searchPhotosResponse)")
                self.searchPhotosResponse = searchPhotosResponse
                
            } catch let error {
                print("Search photos endpoint serialization error \(error.localizedDescription)")
            }
        }
        
        if let urlResponse = urlResponse, let httpResponse = urlResponse as? HTTPURLResponse {
            
            print("Search photos endpoint response status code - \(httpResponse.statusCode)")
        }
    }
    
    func save(searchText: String) {
        var existingArray: [String] = getSaveSearchTextArray()
        existingArray.append(searchText)
        
        
        UserDefaults.standard.set(existingArray, forKey: savedSearchTextArrayKey)
        
        searchTextArray = existingArray
    }
    
    func getSaveSearchTextArray() -> [String] {
        let array: [String] = UserDefaults.standard.stringArray(forKey: savedSearchTextArrayKey) ?? []
        return array
    }
    
//    func sortTextArrayByDate() {
//        // MARK: сортируем массив с помощью closure по дате ввода запроса в поисковик(последний запрос должен стоять первым
//        
//        searchTextArray.sort(by: {searchText1, searchText2 in // метод сорт принимает замыкание для опредления порядка сортировки
//            let date1 = UserDefaults.standard.object(forKey: searchText1) as? Date // мы пытаемся получить дату из UserDefaults для первого текста в массиве
//            let date2 = UserDefaults.standard.object(forKey: searchText2) as? Date
//            
//            if let date1 = date1, let date2 = date2 { // если оба запроса имеют даты, то мы сравниваем эти даты с помощью > для того чтобы узнать какой запрос был сделан позже
//                return date1 > date2
//            }
//            // если один из запросов не имеет даты, а другой имеет, то мы в данном случае возвращаем true, чтобы запрос был впереди списка, иначе просто возвращаем false
//            if date1 == nil && date2 != nil {return true} else {return false}
//        })
//    }
    
    func textArrayUniqueValues() {
        var orderedNoDuplicates = NSOrderedSet(array: searchTextArray).map({$0 as! String})
    }
}

extension MainViewController: UISearchBarDelegate {
    
    // MARK: в добавление кнопки "отменить"  в метод searchBarTextDidEndEditing для отображения ее после начала редактирования текста в поисковой панели
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    // MARK: клавиатура должна скрываться после нажатия на кнопку "отменить" в поисковой панели
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    // MARK: кнопка "отменить" должна скрываться после завершения редактирования текста в поисковой панели
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    // MARK: клавиатура должна скрываться после нажатия "найти"
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        search()
        
    }
}

extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
            
        case imageCollectionView:
            return photos.count
            
        case searchHistoryCollectionView:
            return searchTextArray.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            
        case imageCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
            cell.setup(photo: self.photos[indexPath.item])
            return cell
            
        case searchHistoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTextCollectionViewCell.identifier, for: indexPath) as! SearchTextCollectionViewCell
            
            let sortedHistoryArray = searchTextArray.count - 1 - indexPath.item
            cell.set(title: searchTextArray[sortedHistoryArray])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout: UICollectionViewFlowLayout? = collectionViewLayout as? UICollectionViewFlowLayout
        let horizontalSpacing:CGFloat = (flowLayout?.minimumLineSpacing ?? 0) + collectionView.contentInset.left + collectionView.contentInset.right
        let width:CGFloat = (collectionView.frame.width - horizontalSpacing) / 2
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = self.photos[indexPath.item]
        let url = photo.src.large2X
        
        let vc = ImageScrollViewController(imageURL: url)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
