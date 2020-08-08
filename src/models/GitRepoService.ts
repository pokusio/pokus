import { GitRepo } from "../models/GitRepo";
import * as dtree from 'directory-tree';

// A post request should not contain any repo uid. or ssh_uri
export type GitRepoCreationParams = Pick<GitRepo, "name" | "description" | "https_uri">;


export class GitRepoService {
  public get(repoUid: number): GitRepo {
    console.log("Method not fully implemented : it should retireve git repo JSON from mongodb database")
    // TODO : retrieve git repo from database instead of the test JSON response below
    return {
      repoUid: repoUid, // specific to pokus, allows not to be ited to github or gitlab specific IDs
      description: "This repo version controls The source code of our webite ",
      name: "pokus-fireguns",
      ssh_uri: 'git@gitlab.com:second-bureau/pegasus/pokus/pokus.git',
      https_uri: 'https://gitlab.com/second-bureau/pegasus/pokus/pokus.git',
      languages:  [ 'JavasScript', 'markdown', 'css']
    };

  }
  public getCurrentRepoTree(): Object {

    /// build the Regexp String to exclude paths
    // Split process.env.POKUS_GITOPS to backslash all slash characters
    // this first one works to exclude
    // const tree2 = dtree(process.env.POKUS_GITOPS, { exclude: /\/home\/jbl\/pokus\.dev\/pokus_gitops\/\.git\// });
    // const tree2 = dtree(process.env.POKUS_GITOPS, { exclude: new RegExp('/' + process.env.POKUS_GITOPS + ' \/\.git\//') });
    // const tree3 = dtree(process.env.POKUS_GITOPS, { exclude: new RegExp('/\/home\/jbl\/pokus\.dev\/pokus_gitops\/\.git\//', 'g') });

    /// yes ! finally found a way without having to use any variable or process env var
    const tree = dtree(process.env.POKUS_GITOPS, { exclude: /[\/|a-z|A-Z|0-9]+\/\.git\/[\/|a-z|A-Z|0-9]+/ });



    return tree; // inside the 'src/models/git' folder
  }
  public create(gitRepoCreationParams: GitRepoCreationParams): GitRepo {
    // TODO : create the entry in the mongo db database, so that repo is considered created
    return     {
          repoUid: Math.floor(Math.random() * 10000), // specific to pokus, allows not to be ited to github or gitlab specific IDs
          description: "This repo version controls The source code of our webite ",
          ssh_uri: 'git@gitlab.com:second-bureau/pegasus/pokus/pokus.git',
          languages:  [ 'JavasScript', 'markdown', 'css'],
          ...gitRepoCreationParams,
          // maybe some other fields later.
        }; // inside the 'src/models/git' folder

  }
}
