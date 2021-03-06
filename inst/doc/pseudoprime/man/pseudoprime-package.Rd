\name{pseudoprime-package}
\title{Tests pseudoprimality by Fermat's little theorem}
\description{Tests pseudoprimality by Fermat's little theorem.}
\details{\tabular{ll}{
Package: \tab pseudoprime\cr
Type: \tab Package\cr
Version: \tab 0.1\cr
Date: \tab 2008-08-24\cr
License: \tab GPL (>= 2)\cr
LazyLoad: \tab yes\cr
}

Using the Fermat primality test, pseudoprime checks for primes
probabilistically; the test is fooled every time by Carmichael
numbers.

\code{\link{is.pseudoprime}} checks a number \code{n} for
pseudoprimality, applying Fermat's test \code{times} times.}
\alias{pseudoprime}
\docType{package}
\author{Peter Danenberg \email{pcd@roxygen.org}}
\references{\url{http://en.wikipedia.org/wiki/Fermat's_little_theorem}}
\keyword{package}
\seealso{\code{\link{is.pseudoprime}}}
\examples{is.pseudoprime(13, 4)}
