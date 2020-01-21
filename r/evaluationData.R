#' Teacher Evaluation Data
#' 
#' A dataset containing the count and percent of teachers
#' receiving each evaluation score. Use `vignettes("overview")`
#' to see data details. 
#' 
#' @format a data frame with 21273 rows and 22 variables
#' \describe{
#'   \item{state}{the name of the state}
#'   \item{year}{school year, 2012-13 coded as 2013}
#'   \item{district_name}{descriptive district name}
#'   \item{localid}{nces localid for school district}
#'   \item{NCES_leaid}{nces leaid for school district}
#'   \item{count_teachers}{number of teachers in school district as reported in evaluation files}
#'   \item{count_not_evaluated}{number of teachers without reported evaluations}
#'   \item{count_suppressed}{number of teachers with ratings suppressed for privacy reasons}
#'   \item{count_level1}{number of teachers with lowest rating - typically "ineffective"}
#'   \item{count_level2}{number of teachers with second lowest rating - typically "developing"}
#'   \item{count_level3}{number of teachers with third level rating - typically "effective"}
#'   \item{count_level4}{number of teachers with fourth level rating - typically "highly effective"}
#'   \item{percent_not_evaluated}{percent without evaluations}
#'   \item{percent_suppressed}{percent with suppressed ratings}
#'   \item{percent_level1}{percent with lowest rating}
#'   \item{percent_level2}{percent with second lowest rating}
#'   \item{percent_level3}{percent with third level rating}
#'   \item{percent_level4}{percent with level four rating}
#'   \item{impute_level1}{Was count imputed - see XX for more details}
#'   \item{impute_level2}{Was count imputed - see XX for more details}
#'   \item{impute_level3}{Was count imputed - see XX for more details}
#'   \item{impute_level4}{Was count imputed - see XX for more details}
#' } 
#' @source see \url{https://github.com/williamlief/evaluationDB}