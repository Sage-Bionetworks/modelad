# Load necessary libraries
library(tidytext)
library(dplyr)
library(ggplot2)
library(readr)
library(wordcloud)
library(RColorBrewer)

# Set seed for reproducibility
set.seed(123)

# 1. Load and Clean Data
data_path <- "modelad/scripts/data_PM_Needs.csv"  # File path to the data
survey_data <- read_csv(data_path)

# Clean data: Fill missing titles and filter out empty rows
clean_survey_data <- survey_data %>%
  mutate(`What is your title?` = ifelse(is.na(`What is your title?`), "Not Provided", `What is your title?`)) %>%
  filter(!is.na(`What kind of work do you do?`))

# 2. Word Frequency Analysis
# Concatenate text columns to create a single column for analysis
text_data <- clean_survey_data %>%
  mutate(all_text = paste(
    `What do you think is the #1 project management-related need for performing your work?`,
    `If you had this #1 need satisfied, how would this impact your work?`,
    `What project management-related task or workflow would you like to automate?`,
    sep = " "
  )) %>%
  select(all_text)  # Keep only the concatenated text column

# Tokenize text and remove stop words
text_tokens <- text_data %>%
  unnest_tokens(word, all_text) %>%
  anti_join(stop_words)

# Count the most frequent words
common_words <- text_tokens %>%
  count(word, sort = TRUE) %>%
  filter(n > 5)

# Visualize word frequency with a bar chart
ggplot(common_words, aes(x = reorder(word, n), y = n)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Most Common Project Management Needs", x = "Word", y = "Frequency")

# Generate a word cloud to illustrate key themes
wordcloud(
  words = common_words$word,
  freq = common_words$n,
  min.freq = 5,
  max.words = 100,
  random.order = FALSE,
  rot.per = 0.35,
  scale = c(3, 0.5),  # Adjust word size based on frequency
  colors = brewer.pal(8, "Dark2")  # Use color palette
)

# 3. Sentiment Analysis
# Load Bing sentiment lexicon
bing_sentiment <- get_sentiments("bing")

# Perform sentiment analysis by joining with Bing lexicon
sentiment_data <- text_tokens %>%
  inner_join(bing_sentiment, by = "word") %>%
  count(sentiment)

# Plot sentiment distribution
ggplot(sentiment_data, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  labs(title = "Sentiment Distribution in Survey Responses", x = "Sentiment", y = "Word Count")


# Install and load necessary libraries
install.packages("wordcloud")  # Install if not installed
library(wordcloud)
library(RColorBrewer)

# Example word frequency data (use your actual data instead)
words <- c("management", "project", "data", "communication", "planning", "automation", "team")
freqs <- c(25, 20, 15, 12, 10, 8, 6)

# Display the word cloud
wordcloud(
  words = words,       # Words to display
  freq = freqs,        # Frequency of each word
  min.freq = 1,        # Minimum frequency to include
  max.words = 100,     # Maximum number of words to display
  random.order = FALSE,  # Words are ordered by frequency
  rot.per = 0.35,      # Percentage of words rotated
  scale = c(3, 0.5),   # Word size range
  colors = brewer.pal(8, "Dark2")  # Color palette
)

