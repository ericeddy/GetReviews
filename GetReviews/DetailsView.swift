//
//  DetailsView.swift
//  GetReviews
//
//  Created by Eric Eddy on 2016-11-02.
//  Copyright © 2016 ericeddy. All rights reserved.
//

import UIKit

class DetailsView: UIView {
    
    static let reviewCellHeight: CGFloat = 120.0
    let imgUrl = "https://image.tmdb.org/t/p/"
    let cellImgSize = "w185"
    
    var id: Int = 0
    var contentView: UIView
    //var contentScrollView: UIScrollView
    var poster: UIImageView
    var titleLabel: UILabel
    var reviewScoreLabel: UILabel
    var reviewsTable: UITableView
    var movieDetails: MovieDetailsData?
    var movieReviews: Array<MovieReviewData> = []
    var windowLoading: UIActivityIndicatorView
    
    override init(frame: CGRect) {
        //contentScrollView = UIScrollView()
        //contentScrollView.isScrollEnabled = false
        contentView = UIView()
        contentView.clipsToBounds = true
        poster = UIImageView()
        titleLabel = UILabel()
        reviewScoreLabel = UILabel()
        reviewsTable = UITableView()
        windowLoading = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        windowLoading.hidesWhenStopped = true
        windowLoading.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        addSubview(windowLoading)
        windowLoading.startAnimating()
        
        backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 12
        addSubview(contentView)
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        //contentView.backgroundColor = .blue
        //contentScrollView.addSubview(contentView)
        poster.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(poster)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 32)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        reviewScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewScoreLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        reviewScoreLabel.numberOfLines = 0
        reviewScoreLabel.textAlignment = .center
        contentView.addSubview(reviewScoreLabel)
        reviewsTable.translatesAutoresizingMaskIntoConstraints = false
        reviewsTable.isScrollEnabled = true
        reviewsTable.rowHeight = UITableViewAutomaticDimension
        reviewsTable.estimatedRowHeight = 80
        reviewsTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        reviewsTable.tableFooterView = UIView()
        contentView.addSubview(reviewsTable)
        
        addConstraint(NSLayoutConstraint(item: windowLoading, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0 ))
        addConstraint(NSLayoutConstraint(item: windowLoading, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0 ))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMovieDetailsData(movieData: MovieDetailsData){
        movieDetails = movieData

        let isIpad = AppDelegate.isIPad()
        
        let paddingH: CGFloat = isIpad ? 42.0 : 20.0
        let paddingW: CGFloat = isIpad ? 84.0 : 20.0
        
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: paddingH ))
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -paddingH ))
        
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: paddingW ))
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -paddingW ))
        
        if let posterpath = movieDetails!.posterPath {
            poster.imageFromURL(urlString: imgUrl + cellImgSize + posterpath)
        }
        addConstraint(NSLayoutConstraint(item: poster, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: poster, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 20))
        
        titleLabel.text = movieDetails!.title + " (" + String(movieDetails!.releaseDate.characters.prefix(4)) + ")"
        titleLabel.sizeToFit()
        
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: poster, attribute: .bottom, multiplier: 1, constant: 10))
        
        
        reviewScoreLabel.text = String(movieDetails!.voteAverage) + "/10 -- Based on " + String(movieDetails!.voteCount) + " votes"
        
        addConstraint(NSLayoutConstraint(item: reviewScoreLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: reviewScoreLabel, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: reviewScoreLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 10))
        
        addConstraint(NSLayoutConstraint(item: reviewsTable, attribute: .top, relatedBy: .equal, toItem: reviewScoreLabel, attribute: .bottom, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: reviewsTable, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: reviewsTable, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: reviewsTable, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0))
        
        
    }
    
    func updateReviews() {
        reviewsTable.reloadData()
        reviewsTable.layoutIfNeeded()
    }
    
}
