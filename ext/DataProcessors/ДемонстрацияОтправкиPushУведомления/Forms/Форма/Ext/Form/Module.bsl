#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ФайлСекретногоКлючаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ПараметрыВыбораФайла = ИнициализироватьПараметрыВыбораФайла();
	ПараметрыВыбораФайла.ИмяРеквизита = "ФайлСекретногоКлюча";
	ПараметрыВыбораФайла.Заголовок = НСтр("ru='Выберите файл секретного ключа'");
	ПараметрыВыбораФайла.Фильтр = НСтр("ru='Файлы JSON (*.json)|*.json|Все файлы (*.*)|*.*'");
	ПараметрыВыбораФайла.Расширение = "json";
	
	ВыбратьФайлНаДиске(ПараметрыВыбораФайла, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьКПрограммеOpenSSLНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ПараметрыВыбораКаталога = ИнициализироватьПараметрыВыбораФайла();
	ПараметрыВыбораКаталога.ВыборКаталога = Истина;
	ПараметрыВыбораКаталога.ИмяРеквизита = "ПутьКПрограммеOpenSSL";
	ПараметрыВыбораКаталога.Заголовок = НСтр("ru='Укажите путь к программе OpenSsl'");
	
	ВыбратьФайлНаДиске(ПараметрыВыбораКаталога, СтандартнаяОбработка);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОтправитьУведомление(Команда)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли; 
	
	СекретныйКлюч = ПрочитатьФайлСекретногоКлюча();
	КлючДоступа = fcm_АутентификацияGoogleAPIКлиентСервер.ПолучитьКлючДоступаGoogleAPI(
		СекретныйКлюч,
		fcm_УведомленияКлиентСервер.РазрешениеFCMОтправкаУведомлений(),
		ПутьКПрограммеOpenSSL
	);
	
	Оповещение = fcm_УведомленияКлиентСервер.СоздатьОповещение();
	Оповещение.title = ЗаголовокСообщения;
	Оповещение.body = ТекстСообщения;
	
	Уведомление = fcm_УведомленияКлиентСервер.СоздатьУведомление();
	Уведомление.token = ИдентификаторПолучателя;
	Уведомление.notification = Оповещение;
	
	ИдОповещения = fcm_УведомленияКлиентСервер.ОтправитьУведомление(Уведомление, ПроектFirebase, КлючДоступа);
	
	СообщениеПользователю = Новый СообщениеПользователю;
	СообщениеПользователю.Текст = СтрШаблон(НСтр("ru='Push-уведомление отправлено. ID: %1'"), ИдОповещения);
	СообщениеПользователю.Сообщить();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыбратьФайлНаДиске(ПараметрыВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	РежимВыбора = ?(ПараметрыВыбора.ВыборКаталога,
		РежимДиалогаВыбораФайла.ВыборКаталога,
		РежимДиалогаВыбораФайла.Открытие
	);
	
	ДиалогВыбора = Новый ДиалогВыбораФайла(РежимВыбора);
	ДиалогВыбора.Заголовок = ПараметрыВыбора.Заголовок;
	
	ПолноеИмяФайла = ЭтаФорма[ПараметрыВыбора.ИмяРеквизита];
	
	Если ПараметрыВыбора.ВыборКаталога Тогда
		
		ДиалогВыбора.Каталог = ПолноеИмяФайла;
		
	Иначе
		
		ДиалогВыбора.Расширение = ПараметрыВыбора.Расширение;
		ДиалогВыбора.Фильтр = ПараметрыВыбора.Фильтр;
		
		Если Не ПустаяСтрока(ПолноеИмяФайла) Тогда
			
			Поз = СтрНайти(ПолноеИмяФайла, "\", НаправлениеПоиска.СКонца);
			Если Поз = 0 Тогда
				Поз = СтрНайти(ПолноеИмяФайла, "/", НаправлениеПоиска.СКонца);
			КонецЕсли; 
			
			Если Поз = 0 Тогда
				ДиалогВыбора.ПолноеИмяФайла = ПолноеИмяФайла;
			Иначе
				ДиалогВыбора.Каталог = Лев(ПолноеИмяФайла, Поз - 1);
				ДиалогВыбора.ПолноеИмяФайла = Сред(ПолноеИмяФайла, Поз + 1);
			КонецЕсли; 
			
		КонецЕсли; 
		
	КонецЕсли; 
	
	Оповещение = Новый ОписаниеОповещения("ВыборФайлаНаДискеЗавершение", ЭтотОбъект, ПараметрыВыбора.ИмяРеквизита);
	ДиалогВыбора.Показать(Оповещение);
	
КонецПроцедуры 

&НаКлиенте
Процедура ВыборФайлаНаДискеЗавершение(ВыбранныеФайлы, ИмяРеквизита) Экспорт
	
	Если ТипЗнч(ВыбранныеФайлы) = Тип("Массив") И ВыбранныеФайлы.Количество() > 0 Тогда
		ЭтаФорма[ИмяРеквизита] = ВыбранныеФайлы[0];
	КонецЕсли; 
	
КонецПроцедуры 

&НаКлиенте
Функция ИнициализироватьПараметрыВыбораФайла()
	
	ПараметрыВыбора = Новый Структура;
	ПараметрыВыбора.Вставить("ВыборКаталога", Ложь);
	ПараметрыВыбора.Вставить("ИмяРеквизита", "");
	ПараметрыВыбора.Вставить("Заголовок", "");
	ПараметрыВыбора.Вставить("Фильтр", "");
	ПараметрыВыбора.Вставить("Расширение", "");
	
	Возврат ПараметрыВыбора;
	
КонецФункции 

&НаКлиенте
Функция ПрочитатьФайлСекретногоКлюча()
	
	ЧтениеТекста = Новый ЧтениеТекста(ФайлСекретногоКлюча);
	
	СекретныйКлюч = ЧтениеТекста.Прочитать();
	
	ЧтениеТекста.Закрыть();
	
	Возврат СекретныйКлюч;
	
КонецФункции 

#КонецОбласти