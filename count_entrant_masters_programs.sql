
select distinct
	programSubjectCode,
	programSubject,
	count(*) OVER (PARTITION BY programSubjectCode) AS all_requests,
	count(*) FILTER (WHERE eduorganization_p NOT LIKE '%СибАДИ%') OVER (PARTITION BY programSubjectCode) AS not_sibadi_requests,
	-- процент абитуриентов магистров которые закончили не сибади 
	-- поступающие на определенную программу магистров
	to_char((count(*) FILTER (WHERE eduorganization_p NOT LIKE '%СибАДИ%') OVER (PARTITION BY programSubjectCode))::float
		/
	count(*) OVER (PARTITION BY programSubjectCode), '0.99') as percent_of_program_not_sibadi,
	-- процент не абитуриентов не из СибАДИ от общего кол-во заявлений
	to_char((count(*) FILTER (WHERE eduorganization_p NOT LIKE '%СибАДИ%') OVER (PARTITION BY programSubjectCode))::float
		/
	count(*) OVER (), '0.999') as percent_of_allRequests_not_sibadi 
from (select
		programKind,
		fullFio, -- фио
		programSubject, -- название направление подготовки
		programSubjectCode, -- код направления подготовки
		eduorganization_p -- название организации в дипломе
	from enr_req_competition_ext_view
		join enr14_request_t on enr_req_competition_ext_view.entrantRequestId = enr14_request_t.id -- -- Заявление абитуриента
		left join person_edu_doc_t tedu on enr14_request_t.edudocument_id = tedu.id -- -- Документ об образовании и (или) квалификации
		left join addressitem_t eduaddress on tedu.eduorganizationaddressitem_id = eduaddress.id
	where 
		programSubjectCode like '%.04.%' -- направление магистерской прогрммы
		and takeAwayDocument = 0 -- заявление не забрали
		and master = 1 -- указывает на то что это магистерская образовател. программа
		and (regDate >= '01/09/2021' or enrOrderDate >= '01/09/2021')
		and regDate <= '30/09/2022'
) baseTable