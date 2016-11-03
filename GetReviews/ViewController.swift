//
//  ViewController.swift
//  GetReviews
//
//  Created by Eric Eddy on 2016-11-02.
//  Copyright © 2016 ericeddy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchUrl = "https://api.themoviedb.org/3/search/movie"
    let movieUrl = "https://api.themoviedb.org/3/movie/"
    let apiKey = "?api_key=c05873b80a3fe8eab1d021f464615dd9"
    let searchKey = "&query="
    let reviewKey = "/reviews"
    let imgUrl = "https://image.tmdb.org/t/p/"
    let cellImgSize = "w92"
    let topPadding: CGFloat = 24
    
    var detailsView: DetailsView? = nil
    var tableView: UITableView!
    var topBar: UIView!
    var searchController: UISearchController!
    var shouldShowSearchResults: Bool = false
    var searching: UIActivityIndicatorView!
    
    var searchResults: Array<MovieCellData> = []
    var lastSearch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        topBar = UIView()
        topBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topPadding)
        topBar.backgroundColor = .gray
        
        searching = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        searching.hidesWhenStopped = true
        searching.translatesAutoresizingMaskIntoConstraints = false
        
        tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        
        view.addSubview(topBar)
        view.addSubview(tableView)
        view.addSubview(searching)
        
        setupSearch()
    }
    
    func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        setConstraints()
    }
    
    func setConstraints() {
        
        view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: searching, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: searching, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1, constant: 80))
        
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: topPadding))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 92
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return searchResults.count
        } else {
            if detailsView != nil {
                return detailsView!.movieReviews.count
            } else {
                return 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // your cell coding
        if tableView == self.tableView {
            var cell = tableView.dequeueReusableCell(withIdentifier: MovieTableCell.movieIdentifier) as UITableViewCell?
            if (cell == nil) {
                cell = MovieTableCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: MovieTableCell.movieIdentifier)
            }
            
            let data = searchResults[indexPath.row]
            
            cell!.backgroundColor = .white
            cell!.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
            cell!.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            cell!.textLabel?.text = data.title + " (" + String(data.releaseDate.characters.prefix(4)) + ")"
            cell!.detailTextLabel?.text = String(data.voteAverage) + "/10 -- Based on " + String(data.voteCount) + " votes"
            
            cell!.imageView?.backgroundColor = .black
            cell!.imageView?.image = UIImage.init(color: .black, size: CGSize(width:100, height:100))
            cell!.imageView?.contentMode = .scaleAspectFit
            if let posterpath = data.posterPath {
                cell!.imageView?.imageFromURL(urlString: imgUrl + cellImgSize + posterpath)
            }
            
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: MovieTableCell.reviewIdentifier) as UITableViewCell?
            if (cell == nil) {
                cell = MovieTableCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: MovieTableCell.reviewIdentifier)
            }
            
            let data = detailsView!.movieReviews[indexPath.row]
            cell!.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
            cell!.textLabel?.text = data.author
            cell!.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            cell!.detailTextLabel?.text = data.content
            cell!.detailTextLabel?.numberOfLines = 0
            
            
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cell selected code here
        if tableView == self.tableView {
            showDetails(row: indexPath.row)
        }
    }
    
    func showDetails(row: Int) {
        if detailsView != nil {
            detailsView!.removeFromSuperview()
            detailsView = nil
        }
        detailsView = DetailsView(frame: CGRect.init())
        detailsView!.id = searchResults[row].id
        detailsView!.translatesAutoresizingMaskIntoConstraints = false
        
        searchController.isActive = false
        view.addSubview(detailsView!)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeDetails(gesture:)))
        detailsView!.addGestureRecognizer(tapRecognizer)
        
        view.addConstraint(NSLayoutConstraint(item: detailsView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: detailsView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: detailsView!, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: detailsView!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))

        loadMovieDetails()
    }
    
    func closeDetails(gesture: UIGestureRecognizer){
        
        let point = gesture.location(in: detailsView)
        if detailsView!.contentView.bounds.contains(point) {
            
        } else {
            detailsView!.removeFromSuperview()
            detailsView = nil
            
            searchController.isActive = true
            searchController.searchBar.text = lastSearch
        }
    }
    
    func loadMovieDetails() {
        var request = URLRequest( url: URL(string: movieUrl + String(detailsView!.id) + apiKey )! )
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async(execute: { () -> Void in
                if error != nil{
                    print("Error -> \(error)")
                    //completionHandler(nil, nil, error as Error?)
                }else{
                    self.detailsLoaded(data, response)
                }
            })
            
        })
        task.resume()
    }
    
    func detailsLoaded(_ data: Data?, _ response: URLResponse?) {
        if detailsView == nil { return }
        if let parsedData = try? JSONSerialization.jsonObject(with: data!) as! [String:Any] {
            let id =            parsedData["id"] as! NSNumber
            let title =         parsedData["title"] as! String
            let posterPath =    parsedData["poster_path"] as? String
            let releaseDate =   parsedData["release_date"] as! String
            let voteAverage =   parsedData["vote_average"] as! NSNumber
            let voteCount =     parsedData["vote_count"] as! NSNumber
            
            detailsView!.setMovieDetailsData(movieData: MovieDetailsData(id: id.intValue, title: title, posterPath: posterPath, releaseDate: releaseDate, voteAverage: voteAverage.floatValue, voteCount: voteCount.intValue))
        }
        getReviews()
    }
    
    func getReviews() {
        var request = URLRequest( url: URL(string: movieUrl + String(detailsView!.id) + reviewKey + apiKey )! )
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async(execute: { () -> Void in
                if error != nil{
                    print("Error -> \(error)")
                    //completionHandler(nil, nil, error as Error?)
                }else{
                    self.handleReviews(data, response)
                }
            })
            
        })
        task.resume()
    }
    func handleReviews(_ data: Data?, _ response: URLResponse?) {
        if let parsedData = try? JSONSerialization.jsonObject(with: data!) as! [String:Any] {
            let results = parsedData["results"] as! [[String:Any]]
            let amt = results.count > 5 ? 5 : results.count
            if amt == 0 { return }
            for i in 0...amt-1 {
                let author = results[i]["author"] as! String
                let content = results[i]["content"] as! String
                detailsView?.movieReviews.append(MovieReviewData(author: author, content: content))
            }
            detailsView!.reviewsTable.delegate = self
            detailsView!.reviewsTable.dataSource = self
            detailsView!.updateReviews()
        }
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        makeSearchReq( search: searchString! )
    }
    
    func makeSearchReq( search: String ) {
        if search == "" {
            searchResults.removeAll()
            tableView.reloadData()
            return
        }
        searching.startAnimating()
        lastSearch = search
        
        let fixedSearch = search.replacingOccurrences(of: " ", with: "+")
        
        var request = URLRequest(url: URL(string: searchUrl + apiKey + searchKey + fixedSearch )!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async(execute: { () -> Void in
                if error != nil{
                    print("Error -> \(error)")
                    //completionHandler(nil, nil, error as Error?)
                }else{
                    self.searchComplete(data, response)
                }
            })
            
        })
        task.resume()
    }
    
    
    func searchComplete(_ data: Data?, _ response: URLResponse?) {
        // Parse JSON
        searchResults.removeAll()
        searching.isHidden = true
        
        if let parsedData = try? JSONSerialization.jsonObject(with: data!) as! [String:Any] {
            let results = parsedData["results"] as! [[String:Any]]
            if results.count > 0 {
                for i in 0...results.count-1 {
                    let id =            results[i]["id"] as! NSNumber
                    let title =         results[i]["title"] as! String
                    let posterPath =    results[i]["poster_path"] as? String
                    let releaseDate =   results[i]["release_date"] as! String
                    let voteAverage =   results[i]["vote_average"] as! NSNumber
                    let voteCount =     results[i]["vote_count"] as! NSNumber
                    let popularity =    results[i]["popularity"] as! NSNumber
                    
                    searchResults.append( MovieCellData(id: id.intValue, title: title, posterPath: posterPath, releaseDate: releaseDate, voteAverage: voteAverage.floatValue, voteCount: voteCount.intValue, popularity: popularity.floatValue) )
                }
            }
            searchResults.sort{
                $0.title > $1.title
            }
            searchResults.sort{
                $0.popularity > $1.popularity
            }
        }
        searching.stopAnimating()
        tableView.reloadData()
        
        //print(json)
    }
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        tableView.reloadData()
    }
    
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if detailsView != nil && (detailsView?.movieReviews.count)! > 0 {
            let width = detailsView!.contentView.bounds.width
            let height = detailsView!.reviewsTable.bounds.maxY + 20
            detailsView!.contentView.contentSize = CGSize(width: width, height: height)
        }
    }
     */
    
}
public struct MovieCellData{
    var id: Int
    var title: String
    var posterPath: String?
    var releaseDate: String
    var voteAverage: Float
    var voteCount: Int
    var popularity: Float
}
public struct MovieDetailsData{
    var id: Int
    var title: String
    var posterPath: String?
    var releaseDate: String
    var voteAverage: Float
    var voteCount: Int
}
public struct MovieReviewData{
    var author: String
    var content: String
    
}
class MovieTableCell:UITableViewCell {
    static let movieIdentifier = "movie-cell"
    static let reviewIdentifier = "review-cell"
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if reuseIdentifier == MovieTableCell.reviewIdentifier{
            setupForReviewCell()
        }
    }
    func setupForReviewCell(){
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 10))
        
        let padding:CGFloat = AppDelegate.isIPad() ? 80.0 : 20.0
        
        contentView.addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: padding))
        contentView.addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -padding))
        
        contentView.addConstraint(NSLayoutConstraint(item: detailTextLabel!, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: padding))
        contentView.addConstraint(NSLayoutConstraint(item: detailTextLabel!, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -padding))
        
        contentView.addConstraint(NSLayoutConstraint(item: detailTextLabel!, attribute: .top, relatedBy: .equal, toItem: textLabel!, attribute: .bottom, multiplier: 1, constant: 10))
        
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: detailTextLabel!, attribute: .bottom, multiplier: 1, constant: 10))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
}

