export interface GitRepo {
  repoUid: number; // specific to pokus, allows not to be ited to github or gitlab specific IDs
  description: string;
  name: string; // inferred from the gti repo short name
  ssh_uri: string;
  https_uri: string;
  languages:  string[];
  // maybe some other fields later.
} // inside the 'src/models/git' folder
