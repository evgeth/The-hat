//
//  TutorialViewController.swift
//  thehat
//
//  Created by Eugene Yurtaev on 04/01/16.
//  Copyright © 2016 dpfbop. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    var pageViewController: UIPageViewController!
    var tutorialTitles: [String] = []
    var tutorialImages: [String] = []
    
    var tutorialPages: [TutorialPageViewController] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNavigationBarTitleWithCustomFont(NSLocalizedString("RULES", comment: "Rules"))
        
        
        tutorialTitles = [NSLocalizedString("edit_players", comment: "edit_players"),
                        NSLocalizedString("edit_settings", comment: "edit_settings"),
                        NSLocalizedString("preparation", comment: "preparation"),
                        NSLocalizedString("round", comment: "round"),
                        NSLocalizedString("extra_time", comment: "extra_time"),
                        NSLocalizedString("results", comment: "results"),
                        "new game"]
        tutorialImages = ["edit_players",
                        "edit_settings",
                        "preparation",
                        "round",
                        "extra_time",
                        "results",
                        "new_game"]
//        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        
        tutorialPages = [viewControllerAtIndex(0)!]
        
        
        pageViewController.setViewControllers(tutorialPages, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 40)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension TutorialViewController: UIPageViewControllerDataSource {
    func viewControllerAtIndex(index: Int) -> TutorialPageViewController? {
        if (self.tutorialTitles.count == 0) || (index >= self.tutorialTitles.count) {
            return nil;
        }
        
        // Create a new view controller and pass suitable data.
        let tutorialPage = storyboard?.instantiateViewControllerWithIdentifier("TutorialPageViewController") as! TutorialPageViewController
        tutorialPage.imageName = self.tutorialImages[index]
        tutorialPage.descriptionText = self.tutorialTitles[index]
        tutorialPage.pageIndex = index
        
        return tutorialPage
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! TutorialPageViewController).pageIndex
        
        if index == tutorialTitles.count {
            return nil
        }
        
        return viewControllerAtIndex(index + 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! TutorialPageViewController).pageIndex

        if (index == 0) {
            return nil
        }
        
        return viewControllerAtIndex(index - 1)
    }
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return tutorialTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}