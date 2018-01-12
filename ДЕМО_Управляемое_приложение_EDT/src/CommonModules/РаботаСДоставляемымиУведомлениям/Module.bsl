Процедура НеИспользоватьИдентификаторы(Токены)
	
	Если Токены.Количество() > 0 Тогда
		Выборка = ПланыОбмена.Мобильные.Выбрать();
		Пока Выборка.Следующий() Цикл
			Если Выборка.ИдентификаторПодписчикаДоставляемыхУведомлений <> Неопределено Тогда
				Идентификатор = Выборка.ИдентификаторПодписчикаДоставляемыхУведомлений.Получить();
				Если Идентификатор <> Неопределено И Токены.Найти(Идентификатор.ИдентификаторУстройства) Тогда
					Узел = Выборка.ПолучитьОбъект();
					Узел.ИдентификаторПодписчикаДоставляемыхУведомлений = Неопределено;
					Узел.Записать();
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОтправитьУведомление(Уведомление, Пользователь, Проблемы) Экспорт
	
	ИспользоватьPushУведомления = Константы.ИспользоватьPushУведомления.Получить();
	ИспользоватьAPNS = Константы.ИспользоватьAPNS.Получить();
	ИспользоватьGCM = Константы.ИспользоватьGCM.Получить();
	ИспользоватьWNS = Константы.ИспользоватьWNS.Получить();
	ИспользоватьСервис = ? (ИспользоватьPushУведомления = Перечисления.PushУведомления.ИспользоватьВспомогательныйСервис, Истина, Ложь);
	Если Не ЗначениеЗаполнено(ИспользоватьPushУведомления)
		ИЛИ ИспользоватьPushУведомления = Перечисления.PushУведомления.НеИспользовать Тогда
		Возврат;
	КонецЕсли;
	Выборка = ПланыОбмена.Мобильные.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если Выборка.ИдентификаторПодписчикаДоставляемыхУведомлений <> Неопределено Тогда
			Если Пользователь = Неопределено ИЛИ Пользователь = Выборка.Пользователь Тогда
				Идентификатор = Выборка.ИдентификаторПодписчикаДоставляемыхУведомлений.Получить();
				Если Идентификатор <> Неопределено И
					 ((Идентификатор.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.APNS И (ИспользоватьAPNS = Истина ИЛИ ИспользоватьСервис = Истина))
						ИЛИ (Идентификатор.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.GCM И ИспользоватьGCM = Истина ИЛИ ИспользоватьСервис = Истина)
						ИЛИ (Идентификатор.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.WNS И ИспользоватьWNS = Истина ИЛИ ИспользоватьСервис = Истина)) Тогда
					Уведомление.Получатели.Добавить(Идентификатор);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если Уведомление.Получатели.Количество() > 0 Тогда
		ДанныеАутентификации = "";
		Сертификат = Неопределено;
		Если ИспользоватьСервис = Истина Тогда
			ДанныеАутентификации = Константы.ЛогинСервисаПередачиPushУведомлений.Получить();
		Иначе
			ДанныеАутентификации = Новый Соответствие();
			Если ИспользоватьGCM = Истина Тогда
				ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.GCM] = Константы.КлючCервераОтправителяGCM.Получить();
			КонецЕсли;
			Если ИспользоватьAPNS = Истина Тогда
				Сертификат = Константы.СертификатМобильногоПриложенияIOS.Получить();
				Если Сертификат <> Неопределено Тогда
					Сертификат = Сертификат.Получить();
					Если Сертификат <> Неопределено Тогда
						ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.APNS] = Сертификат;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			Если ИспользоватьWNS = Истина Тогда
				МаркерДоступа = Константы.МаркерДоступаWNS.Получить();
				Если МаркерДоступа = "" Тогда
					МаркерДоступа = ПолучитьМаркерДоступа();
				КонецЕсли;
				ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.WNS] = МаркерДоступа;
				
			КонецЕсли;
		КонецЕсли;
		
		УдаленныеТокены = Новый Массив;
		ОтправкаДоставляемыхУведомлений.Отправить(Уведомление, ДанныеАутентификации, УдаленныеТокены, ИспользоватьСервис, Проблемы);
		НеИспользоватьИдентификаторы(УдаленныеТокены);
		
		Если Проблемы.Количество() > 0 Тогда
			// Проверяем, возможно токен устарел
			ЗапроситьТокен = Ложь;
			Для каждого Проблема Из Проблемы Цикл
				Если Проблема.ТипОшибки = ТипОшибкиОтправкиДоставляемогоУведомления.ОшибкаДанныхАутентификации Тогда
					Для каждого Получатель Из Проблема.Получатели Цикл
						Если Получатель.ТипПодписчика = ТипПодписчикаДоставляемыхУведомлений.WNS Тогда
							ЗапроситьТокен = Истина;
							Прервать;
						Конецесли;
					КонецЦикла;
				Конецесли;
				Если ЗапроситьТокен Тогда
					Прервать;
				Конецесли;
			КонецЦикла;
			Если ЗапроситьТокен Тогда
				УдаленныеТокены.Очистить();
				Проблемы.Очистить();
				МаркерДоступа = ПолучитьМаркерДоступа();
				ДанныеАутентификации[ТипПодписчикаДоставляемыхУведомлений.WNS] = МаркерДоступа;
				ОтправкаДоставляемыхУведомлений.Отправить(Уведомление, ДанныеАутентификации, УдаленныеТокены, ИспользоватьСервис, Проблемы);
				НеИспользоватьИдентификаторы(УдаленныеТокены);
			Конецесли;
		КонецЕсли;
		
		Если Сертификат <> Неопределено Тогда
			УдаленныеТокены = ОтправкаДоставляемыхУведомлений.ПолучитьИсключенныхПолучателей(Сертификат, ИспользоватьСервис);
			НеИспользоватьИдентификаторы(УдаленныеТокены);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьМаркерДоступа()
	
	ИдентификаторПриложения = Константы.ИдентификаторПриложенияWNS.Получить();
	КлючПриложения = Константы.КлючПриложенияWNS.Получить();
	МаркерДоступа = ОтправкаДоставляемыхУведомлений.ПолучитьМаркерДоступа(ИдентификаторПриложения, КлючПриложения);
	Константы.МаркерДоступаWNS.Установить(МаркерДоступа);
	Возврат МаркерДоступа;
	
КонецФункции

