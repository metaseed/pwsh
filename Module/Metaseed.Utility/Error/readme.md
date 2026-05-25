## Push-Error / Pop-Error

Push-Error and Pop-Error are used to manage the error stack.

- **Push-Error** (`PushErr`): save the error stack and clear the error stack
- **Pop-Error** (`PopError`): restore the error stack and append current errors (default)
- **Pop-Error -OmitErrorsAfterPush**: restore only the last saved error stack, discarding current errors
- ** $error.clear() **: clear errors