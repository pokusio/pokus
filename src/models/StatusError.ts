export interface StatusError {
  id: number;
  message: string;
  status?: filestatus;
}

export type filestatus = 'InternalServerError' | 'FileNotFoundInWorkspace';
