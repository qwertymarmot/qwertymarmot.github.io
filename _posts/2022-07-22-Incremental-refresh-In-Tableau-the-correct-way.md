---
title: Incremental refresh in Tableau the correct way
author: Brandon
---
## A little background
At my job, I use Tableau to create reports and visualize data from our Integrated Library System. Each member library uses this system to complete transactions and store information about library materials and patrons. 

The database, by default, is set to only store a few months’ worths of circulation data. This is not enough data to assist in yearly reporting or gathering historical information. So, we started by increasing the retention of circulation data in the database to 380 days. This would let us collect an entire year’s worth of data, plus an additional 15 days of buffer to run reports or queries. As long as we remembered to run our reports or questions in this 15-day window, we were covered. This again becomes a difficult task for everyone to remember.

<figure>
<img src="https://images.unsplash.com/photo-1597852074816-d933c7d2b988?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80"/>
<figcaption>Photo by <a href="https://unsplash.com/@benjaminlehman?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">benjamin lehman</a> on <a href="https://unsplash.com/s/photos/database?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
</figcaption>
</figure>

The next step was creating an export of data using Tableau at the beginning of each year. These exports were stored locally on my computer (I know, not the best approach). This again became cumbersome, as I could not automate the connections of reports sitting on our Tableau server to these exported files. 

Finally, I decided it was time to incorporate a separate database for storing these exported circulation files. For the years 2021 and 2022, I pulled exports from the circulation database at the beginning of January and imported them into a database. Now I had access to these historical files. With a bit of data magic using Tableau Data Prep, I could figure out how to unite these two files with our current circulation database file to get data ranging from 2020-current. This was a game changer in our circulation history and was how we have been operating until I had a spark of inspiration.

## Introducing Incremental Refresh
Several months ago, I noticed in Tableau Data Prep the new option to output to a [database table][1]. I immediately thought about how I could automate the circulation exports that I had been doing manually at the end of every year. With the output to a database table, I could post the Tableau Data Prep flow to our Tableau server and have it set to run every day. By using the incremental refresh option, Tableau would pull only the new rows from the circulation system.

<figure>
<img src="https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1476&q=80"/>
<figcaption>Photo by <a href="https://unsplash.com/@goumbik?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Lukas Blazek</a> on <a href="https://unsplash.com/s/photos/data-visualization?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a> 
</figcaption>
</figure>

It took me a few weeks before I was able to get the time to initially set this up. We have been using an MS SQL Express database for our other files, so I intended to use the same database. In my initial set up I set incremental refresh enabled on the connection to the live system but left it off on the two exported connections that were later union, more on this later. I was also connecting to the MS SQL Express server with Windows authentication. Initially, I ran the flow as a full refresh to set the stage for the incremental refreshes. The full refreshed worked fine in the Tableau Data Prep program. So, I posted the flow file to the Tableau server and set it to a scheduled run. After a few days, I went back to the Tableau server to see if the refreshes were running and was met by errors. I tracked down the problems and found that to run incremental refresh, I needed to use a regular database user account rather than Windows authentication.

So, I resolved this issue and switched over to a regular database user account. This time I decided I was going to see this through and make sure the incremental refreshes were able to run before I left. Remember that I still had incremental refresh set on just the one live connection. Because of this, I kept having errors. I troubleshooted the problem for several hours and decided to take lunch to step away from the problem. That was when I had the epiphany that I needed to also configure the incremental refresh settings on the other two connections as they introduced additional rows that the system was seeing as new and was causing the MS SQL Express database to hit the size limit because I was essentially duplicating those two files with each refresh. 

Now I have those two issues fixed, and the incremental refreshes seem to be running correctly. I look forward to using this data to save ourselves some trouble in the future when running reports or looking at checkout history of a specific material.

[1]:	https://www.tableau.com/about/blog/2020/7/introducing-tableau-prep-write-database
