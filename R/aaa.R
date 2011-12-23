
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(paste("\n", paste(rep("*", 47), collapse = ""), "\n",
                              " Note that roxygen is no longer being actively\n",
                              " developed. Please use its successor roxygen2!\n",
                              paste(rep("*", 47), collapse = ""), "\n"))
  return(TRUE)
}
	