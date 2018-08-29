# COCO-demos
Open source demonstrations using COCO from all over the world.

## What's this?
This repository aims to collect demonstrations using the [Continuation Core and Toolboxes (COCO)][url-coco] MATLAB platform, created by [Harry Dankowicz][url-hdankowicz] and [Frank Schilder][url-fschilder].

Since the [Recipes for Continuation book][url-recipes] contains many entry level examples and demos, contributors of this repository might assume that visitors have a basic proficiency in COCO.

## How to contribute?
If you have a demonstration you would like to share, you should:

0. Send me a e-mail (`gyebro at mm.bme.hu`) with your GitHub username, and I'll add you as a collaborator.
1. Clone this repository to create a local copy `git clone https://github.com/Gyebro/coco-demos.git`
2. Create a branch for yourself (every contributor should have his/her branch where his/her demonstrations are developed). `git checkout -b YourBranchName`
3. Prepare your demo(s) on your branch in subfolders (do not directly place files in the root of the repository), you can stage your changes and save them as one or more commits (`git add ...` then `git commit -m "Description of changes"`).
4. Once you are done, make sure to push your changes to the origin. `git push -u origin YourBranchName`.
5. If your contribution is ready, [create a pull request][url-pull] to initiate merging your work into the main `master` branch.
Alternatively: if you are not (yet) a collaborator, you can [fork the repository and propose changes similarly via pull requests][url-fork-explained].

*Note: if you are not familiar with Git*, consider using a GUI client for creating your branch, commiting changes, etc. Easy to use clients are: [GitKraken][url-gitkraken] and [SourceTree][url-sourcetree].

*Note 2:* if you wish to completely skip the version control part, you can send your demonstrations to me directly via e-mail: `gyebro at mm.bme.hu`.

## What to include in your contribution?
Please include the following details in your demo:

- Your name
- Contact details: web page or e-mail address
- Date: e.g. `2018 Aug 30` *(Don't add version to your files, Git will handle that.)*
- COCO version: e.g. `2017 Nov 18`
- If possible: include some documentation about the problem and the main steps of your COCO-solution. (A simple `readme.txt` is sufficient, a short `TeX/Doc/PDF` is preferred.)
- Optionally: include a script named `test.m` which contains a single function `result = test()` returning `true / logical 1` if your solution runs without errors.

## Example contribution
An example demo can be found in the [`gyebro` branch][url-gyebro-branch], you can see the commits I've made in the [commits list][url-gyebro-commits], and the [#1 pull request][url-gyebro-pull] about merging the demo to the `master` branch.

Generally contributors should work on their demos using their branches and initiate a pull request every time a particular demonstration is complete. Incomplete / unfinished demos are accessible at all times by looking at the corresponding branch.

[url-coco]: https://sourceforge.net/projects/cocotools/
[url-recipes]: https://epubs.siam.org/doi/book/10.1137/1.9781611972573
[url-hdankowicz]: http://danko.mechanical.illinois.edu/
[url-fschilder]: http://www.dtu.dk/english/service/phonebook/person?id=58602
[url-pull]: https://github.com/Gyebro/coco-demos/pulls
[url-gitkraken]: https://www.gitkraken.com/
[url-sourcetree]: https://www.sourcetreeapp.com/
[url-gyebro-branch]: https://github.com/Gyebro/coco-demos/tree/gyebro
[url-gyebro-commits]: https://github.com/Gyebro/coco-demos/commits/gyebro
[url-gyebro-pull]: https://github.com/Gyebro/coco-demos/pull/1
[url-fork-explained]: https://github.com/MarcDiethelm/contributing/blob/master/README.md