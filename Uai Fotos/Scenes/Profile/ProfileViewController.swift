//
//  ProfileViewController.swift
//  Uai Fotos
//
//  Created by Elifazio Bernardes da Silva on 13/12/2017.
//  Copyright (c) 2017 Uai Fotos. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import SwiftyAvatar
import Spring

protocol ProfileDisplayLogic: class {
    func displayUser(viewModel: Profile.User.ViewModel)
}

class ProfileViewController: UIViewController, ProfileDisplayLogic {
    var interactor: ProfileBusinessLogic?
    var router: (NSObjectProtocol & ProfileRoutingLogic & ProfileDataPassing)?
    
    var user: Profile.User.ViewModel.DisplayUser?
    var photoViewMode: Int = 1
    
    @IBOutlet weak var collectionView: UICollectionView!
    // constraint de altura da collection para ser alterada de acordo com o contentsize.height
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userAvatar: SwiftyAvatar!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var numberOfFollowingLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    
    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter()
        let router = ProfileRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // faz com a que a celula fique com o tamanho dinâmico
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
        }
        self.collectionView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        interactor?.getUser()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let size = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                self.collectionViewHeightConstraint.constant = size.height
            }
        }
    }
    
    @IBAction func multiColumnButtonTouch(_ sender: SpringButton) {
        PhotoCollectionViewCell.horizontalPhotoNumber = 3
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }

    @IBAction func oneColumnButtonTouch(_ sender: SpringButton) {
        PhotoCollectionViewCell.horizontalPhotoNumber = 1
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }
    
    
    
    func displayUser(viewModel: Profile.User.ViewModel) {
        self.user = viewModel.displayUser
        self.userAvatar.kf.setImage(with: self.user?.avatar)
        self.numberOfPhotosLabel.text = self.user?.publications
        self.numberOfFollowingLabel.text = self.user?.following
        self.numberOfFollowersLabel.text = self.user?.followers
        self.userDescriptionLabel.attributedText = self.user?.bio
        self.navigationItem.title = self.user?.name
        self.collectionView.reloadData()
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.user?.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell

        if let photoUrl = self.user?.photos[indexPath.row] {
            cell.imageGallery.kf.indicatorType = .activity
            cell.imageGallery.kf.setImage(with: photoUrl)
        }
 
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.router?.routeToActivityDetail(segue: nil)
        self.collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        TipInCellAnimator.fadeIn(cell: cell.contentView)
    }
}
