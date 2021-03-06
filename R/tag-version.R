tag_version_impl <- function(force) {
  stopifnot(length(git2r::status(".", unstaged = FALSE, untracked = FALSE)$staged) == 0)

  current_news <- get_current_news()
  desc <- desc::desc(file = "DESCRIPTION")
  version <- desc$get_version()

  tag <- paste0("v", version)
  if (tag %in% names(git2r::tags())) {
    if (!force) {
      stop("Tag ", tag, " exists, use `force = TRUE` to overwrite.", call. = FALSE)
    }

    message("Deleting tag ", tag)
    git2r::tag_delete(".", tag)
  }

  message("Creating tag ", tag)
  msg_header <- paste0(desc$get("Package"), " ", version)
  git2r::tag(".", tag, message = paste0(msg_header, "\n\n", current_news))

  message("Tag message:")
  message(msg_header)
  message()
  walk(current_news, message)
}

get_current_news <- function() {
  news_path <- "NEWS.md"
  news <- readLines(news_path)
  top_level_headers <- grep("^# [a-zA-Z][a-zA-Z0-9.]+[a-zA-Z0-9] [0-9.-]+", news)
  stopifnot(top_level_headers[[1]] == 1)

  if (length(top_level_headers) == 1) {
    current_news <- news[-1]
  } else {
    current_news <- news[seq.int(top_level_headers[[1]] + 1, top_level_headers[[2]] - 1)]
  }

  current_news <- paste(current_news, collapse = "\n")
  gsub("^\n*(.*[^\n])\n*$", "\\1", current_news)
}
