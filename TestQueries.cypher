// 1. Return what company programmer 'fp210' works for
MATCH (p:Programmer {firstName: 'fp210'})-[w:`works for`]->(c:Company) 
RETURN p.id, c.name

// 10. How many users use project 623? ANS: 36
MATCH (u:User_P)-[r:`designed for`]-(p:Project {id:623})
WITH count(u) as Num_Users_of_Proj_623
RETURN Num_Users_of_Proj_623


// 11. Returning all projects which user 1 uses
MATCH (u:User_P {id: 1})-[r:`designed for`]-(p:Project)
RETURN u,p


// 12. RETURN all projects from all companies which were written in Java or Python which are currently in production and 
// for which there are more than 2 programmers managing onsite support
MATCH (J_OSS)-[m1:`managed by`]->(jp:Programmer)
WITH J_OSS,count(jp) as jpCount
WHERE jpCount > 2

MATCH (J_OSS:Onsitesupport)-[:`provided for`]->(J_proj:Project{inProduction:'true',language:'Java'})

RETURN J_proj.id as ProjID

UNION ALL

MATCH (P_OSS)-[m2:`managed by`]->(pp:Programmer)
WITH P_OSS,count(pp) as ppCount
WHERE ppCount > 2

MATCH (P_OSS:Onsitesupport)-[:`provided for`]->(P_proj:Project{inProduction:'true',language:'Python'})

RETURN P_proj.id as ProjID

// 2. Return all programmers who work for company 'C80'
MATCH (p:Programmer)-[w:`works for`]->(c:Company{name: 'C80'}) 
RETURN p.id as ProgrammerID, c.name as CompanyName

// 3. How many companies have exactly 3 employees
MATCH (p:Programmer)-[w:`works for`]->(c:Company) 
WITH c, count(p) as employees
WHERE employees = 3
RETURN count(employees) as NumCompaniesWith3Employees


// 4. Which company has the most number of programmers (employees) and how many employees do they have?
MATCH (p:Programmer)-[w:`works for`]->(company:Company)
RETURN company.name as Company, COLLECT(p.firstName) as Programmers, count(p) as NumProgrammers
ORDER BY SIZE(Programmers) DESC LIMIT 10


// 5. What programmers have more than 3 years of experience, who also manage onsite support 
// for a python project?
MATCH (oss:Onsitesupport)-[:`provided for`]-(pj:Project{language:'Python'})
MATCH (oss)-[:`managed by`]-(pg:Programmer)
WHERE pg.yearsOfExperience > 3
RETURN oss.id, collect(pg.id) as Programmers, collect(pg.yearsOfExperience) as YearsExperience


// 6. Given a client, return all the projects written in Rust for which the client attended a demo of the project
// Degree 2 query, with specific properties of objects
MATCH (client:Client{id:1001})-[r:attends]-(demos:Demo)-[r2:demoing]-(rustProjects:Project{language:'Rust'})
RETURN rustProjects.id as RustProject, client.id as Client, demos.id as Demo

// 7. Given a company, return all of the projects currently in production
// Degree 1, high number of specific properties to search through
MATCH (company:Company{id:11})-[r:`belongs to`] -(pj:Project{inProduction:'false'})
RETURN pj.id as projectsNotInProduction,company.name as Company


// 8-2. Different approach
MATCH (d:Demo)-[r:demoing]->(p:Project{language:'Rust'})
MATCH (d)-[:`presented by`]->(tw:Salesperson{trustworthy:'true'})
MATCH (c:Client)-[:attends]->(d)
RETURN SIZE(collect(DISTINCT c))

// 8. From all companies with at least one Rust project, RETURN all of the clients of that company who attended a demo of a // Rust project presented by a trustworthy salesperson
MATCH (companies)<-[r:`belongs to`]-(rustProjects:Project{language:'Rust'})
MATCH (clients)-[h:hires]->(companies)
MATCH (rustDemos:Demo)-[d:demoing]->(rustProjects)
MATCH (twSalesPeople:Salesperson{trustworthy:'true'})
MATCH ((rustDemos)-[:`presented by`]-(twSalesPeople))
MATCH (clients)-[:attends]->(rustDemos)
RETURN SIZE(collect(DISTINCT clients))


// 9. Given a company, RETURN all of the programmers who 
// manage onsite support for all projects written in RUST at that company 
MATCH (C492:Company{name:'C492'})<-[r:`belongs to`]-(rp:Project{language:'Rust'})
MATCH (rp)<-[:`provided for`]-(oss:Onsitesupport)
MATCH (pg:Programmer)-[:`managed by`]-(oss)
RETURN pg.id as programmer, C492.id as company, rp.id as RustProject, oss.id as onSiteSupportID