create database library;
use library;

-- publisher -- doubt- for 6th and 9th row phone numbers are not clear.
create table publisher (
publisher_PublisherName varchar(255) primary key,
publisher_PublisherAddress varchar(255) not null,	
publisher_PublisherPhone varchar(30) not null
);


-- library_branch
create table library_branch (
library_branch_branchID int auto_increment primary key,
library_branch_BranchName varchar(255) not null,
library_branch_BranchAddress varchar(255) not null
);


-- borrower 
create table borrower (
borrower_CardNo int auto_increment primary key,	
borrower_BorrowerName varchar(255) not null,	
borrower_BorrowerAddress varchar(255) not null,	
borrower_BorrowerPhone varchar(30) not null
);


-- books
create table books (
books_bookID int auto_increment primary key,
books_title varchar(255) default null,
books_publishername varchar(255) default null,
constraint fk_publisher_publishername foreign key(books_publishername) references publisher(publisher_PublisherName)
on update cascade
on delete cascade
);


-- book_loans  -- doubt cannot import some dates from file.
create table book_loans(
book_loans_loansID int auto_increment primary key ,
book_loans_bookID int not null,
book_loans_branchID int not null,
book_loans_cardNo int not null ,
book_loans_dateout varchar(255) default null,
book_loans_duedate varchar(255) default null,
constraint fk_borrower_cardNo foreign key (book_loans_cardNo) references borrower(borrower_CardNo),
constraint fk_books_bookID foreign key (book_loans_bookID) references books(books_bookID),
constraint fk_books_branchID foreign key (book_loans_branchID) references library_branch(library_branch_branchID)
);

-- replacing '/' with '-'
update book_loans
set 
book_loans_dateout = replace(book_loans_dateout,'/','-'),
book_loans_duedate = replace(book_loans_duedate,'/','-')
where book_loans_dateout like '%/%'or book_loans_duedate like '%/%';


-- book_copies
create table book_copies (
book_copies_copiesID int auto_increment primary key,
book_copies_bookID int not null,
book_copies_branchID int not null,
book_copies_no_of_copies int not null,
constraint fk_book_copies_bookID foreign key (book_copies_bookID) references books(books_bookID),
constraint fk_book_copies_branchID foreign key (book_copies_branchID) references library_branch(library_branch_branchID)
on delete cascade
);


-- book_authors
create table book_authors (
book_authors_authorID int auto_increment primary key ,
book_authors_BookID int default null, 	
book_authors_AuthorName varchar(255) default null,
constraint fk_authors_bookID foreign key (book_authors_BookID) references books(books_BookID)
);

-- Task Questions
-- 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

select b.books_title as title ,lb.library_branch_branchname as branch_name,count(*) as count_of_copies from books b
join book_copies bc 
on bc.book_copies_bookID = b.books_bookID
join library_branch lb 
on lb.library_branch_branchID = bc.book_copies_branchID
where b.books_title = 'The Lost Tribe' and lb.library_branch_branchname = 'Sharpstown';

-- method - 2

select b.books_title as title ,lb.library_branch_branchname as branch_name, (
select count(*) from book_copies bc
where b.books_bookID = bc.book_copies_bookID and lb.library_branch_branchID = bc.book_copies_branchID) as count_of_copies
from books b
join library_branch lb
on  1=1 
where b.books_title = 'The Lost Tribe' and lb.library_branch_branchname = 'Sharpstown'; 

-- method - 3 

with count_copies as(
select  b.books_title as title ,lb.library_branch_branchname as branch_name,count(*) as count_of_copies 
from books b
join book_copies bc
on bc.book_copies_bookID = b.books_bookID
join library_branch lb
on lb.library_branch_branchID = bc.book_copies_branchID
group by  b.books_title,lb.library_branch_branchname)

select title,branch_name,count_of_copies 
from count_copies 
where title = 'The Lost Tribe' and branch_name = 'Sharpstown'; 


-- 2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?

select lb.library_branch_branchname as branch_name, count(b.books_title) as each_branch from books b
join book_copies bc 
on bc.book_copies_bookID = b.books_bookID 
join library_branch lb
on lb.library_branch_branchID = bc.book_copies_branchID 
where b.books_title = 'The Lost Tribe'
group by lb.library_branch_branchname ;

-- 3.Retrieve the names of all borrowers who do not have any books checked out.
select b.borrower_borrowername as names from borrower b
left join book_loans bl
on bl.book_loans_cardNo = b.borrower_cardno 
where bl.book_loans_loansID is null;


/* 4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, 
retrieve the book title, the borrower's name, and the borrower's address. */

select b.books_title as title, br.borrower_borrowername as name,br.borrower_borroweraddress as address 
from book_loans bl
join books b on b.books_bookID = bl.book_loans_bookID 
join library_branch lb on lb.library_branch_branchID = bl.book_loans_branchID
join borrower br on br.borrower_cardno = bl.book_loans_cardno
where lb.library_branch_BranchName = 'Sharpstown' and bl.book_loans_duedate = '2-3-18';


-- 5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch

with library_branche_loaned_books as (
select lb.library_branch_branchname as branchname,count(bl.book_loans_bookID) as total_books_loaned from book_loans bl
join library_branch lb
on lb.library_branch_branchId = bl.book_loans_branchID 
group by lb.library_branch_branchID)

select branchname,total_books_loaned from library_branche_loaned_books
order by total_books_loaned desc;

-- method - 2
select lb.library_branch_branchname as branchname,count(bl.book_loans_bookID) as total_books_loaned 
from book_loans bl
join library_branch lb
on lb.library_branch_branchId = bl.book_loans_branchID 
group by lb.library_branch_branchname
order by total_books_loaned  desc;

-- 6.Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.

select b.borrower_borrowername as name ,b.borrower_borroweraddress as address ,count(book_loans_bookID) as books_checkedout
from borrower b
join book_loans bl
on bl.book_loans_cardno = b.borrower_cardno 
group by b.borrower_cardno,name ,address
having count(book_loans_bookID) > 5;


-- 7.For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name 
-- is "Central".

select b.books_title, (
select count(*) from book_copies bc 
join library_branch lb 
on lb.library_branch_branchID = bc.book_copies_branchID 
where bc.book_copies_bookID = b.books_bookID and lb.library_branch_branchname = 'central') as no_of_copies
from books b
join book_authors ba
on ba.book_authors_bookID = b.books_bookID 
where ba.book_authors_authorname = 'Stephen King';

with cte as (
select b.books_title,count(*) as cnt from book_copies bc
join library_branch lb
on lb.library_branch_branchID = bc.book_copies_branchID 
where lb.library_branch_branchname = 'central' 
group by b.books_title)  
select 








