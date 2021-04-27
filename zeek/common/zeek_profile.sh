export PATH=$PATH:/zeek/bin

bro_grep() {
    grep -E "(^#)|$1" "$2";
}
alias bro-column="sed \"s/fields.//;s/types.//\" | column -s $'\t' -t"
alias bro-grep="bro_grep"
alias zeek-column="sed \"s/fields.//;s/types.//\" | column -s $'\t' -t"
alias zeek-grep="bro_grep"

