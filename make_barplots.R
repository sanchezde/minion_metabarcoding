#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("need Qiime2 taxonomy file", call.=FALSE)
} else if (length(args)==1) {
  args[2] = "barplot_results.pdf"
}

library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)

infile <- read_csv(args[1])

metadata <- infile %>% 
  select(index, Type:Description)

taxa <- infile %>% 
  select(-Type:-Description)

final <- taxa %>% 
  gather(key = "ID", value = "Reads", 2:ncol(taxa)) %>% 
  separate(ID, c("Phylum",
                 "Class",
                 "Order",
                 "Family",
                 "Genus",
                 "Species"), sep = ";") %>% 
  filter(Species != "__", Species != "") %>% 
  full_join(metadata) %>% 
  arrange(desc(Type)) %>% 
  filter(Reads != 0)

final$Species <- str_replace_all(final$Species, '_', ' ')
final$Species <- str_replace_all(final$Species, ' 1', '')

write_csv(final, "taxa_table.csv")

check <- final %>%
  filter(Common == "Bat.Community")

final %>%
  filter(Reads >= 1) %>% 
  group_by(index, Species) %>% 
  summarize(Reads = sum(Reads)) %>% 
  ggplot(aes(x = index, y = Reads, fill = Species)) +
  geom_bar(stat = "identity", position = "fill", color = "black") +
  coord_flip() +
  labs(x = "DNA source", y = "Percent reads (log10)", fill = "Species detected") +
  scale_y_log10() +
  #scale_fill_manual(values = cbPalette) +
  theme(legend.position = "right",
        text = element_text(color = "black"),
        legend.text = element_text(face = "italic"))

ggsave("result_barplot.pdf")
  
file.exists("Rplots.pdf")
file.remove("Rplots.pdf")



